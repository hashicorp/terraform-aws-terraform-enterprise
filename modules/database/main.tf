# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_string" "postgresql_password" {
  # Always generate a password as AWS RDS requires it even for IAM auth
  length           = 128
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?"
}

resource "aws_security_group" "postgresql" {
  description = "The security group of the PostgreSQL deployment for TFE."
  name        = "${var.friendly_name_prefix}-tfe-postgresql"
  vpc_id      = var.network_id
}

resource "aws_security_group_rule" "postgresql_tfe_ingress" {
  security_group_id        = aws_security_group.postgresql.id
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.tfe_instance_sg
}

resource "aws_security_group_rule" "postgresql_tfe_egress" {
  security_group_id        = aws_security_group.postgresql.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.tfe_instance_sg
}

resource "aws_security_group_rule" "postgresql_ingress" {
  security_group_id = aws_security_group.postgresql.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.network_private_subnet_cidrs
}

resource "aws_security_group_rule" "postgresql_egress" {
  security_group_id = aws_security_group.postgresql.id
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.network_private_subnet_cidrs
}

resource "aws_db_subnet_group" "tfe" {
  name       = var.friendly_name_prefix
  subnet_ids = var.network_subnets_private
}

resource "aws_db_instance" "postgresql" {
  allocated_storage = 20
  engine            = "postgres"
  instance_class    = var.db_size
  # AWS RDS requires a password even for IAM auth, but IAM takes precedence when enabled
  password          = random_string.postgresql_password.result
  # no special characters allowed
  username = var.db_username

  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = var.db_backup_retention
  backup_window               = var.db_backup_window
  db_subnet_group_name        = aws_db_subnet_group.tfe.name
  delete_automated_backups    = true
  deletion_protection         = false
  engine_version              = var.engine_version
  identifier_prefix           = "${var.friendly_name_prefix}-tfe"
  max_allocated_storage       = 0
  multi_az                    = var.allow_multiple_azs
  # no special characters allowed
  db_name                = var.db_name
  port                   = 5432
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = var.kms_key_arn
  storage_type           = "gp2"
  vpc_security_group_ids = [aws_security_group.postgresql.id]
  
  # Enable IAM authentication when postgres_enable_iam_auth is true
  iam_database_authentication_enabled = var.postgres_enable_iam_auth
}

# Database user setup for IAM authentication
# Creates the IAM database user in PostgreSQL and grants rds_iam role
resource "null_resource" "postgresql_iam_user_init" {
  # Only create when IAM authentication is enabled and IAM username is provided
  count = var.postgres_enable_iam_auth && var.db_iam_username != "" ? 1 : 0

  depends_on = [aws_db_instance.postgresql]

  # Use triggers to recreate if key parameters change
  triggers = {
    db_endpoint    = aws_db_instance.postgresql.endpoint
    iam_username   = var.db_iam_username
    db_username    = aws_db_instance.postgresql.username
    db_name        = aws_db_instance.postgresql.db_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -e

      echo "Setting up PostgreSQL IAM user: ${var.db_iam_username}"
      export PGPASSWORD="${random_string.postgresql_password.result}"
      
      # Wait for database to be ready
      max_attempts=30
      attempt=0
      until psql -h ${aws_db_instance.postgresql.endpoint} -U ${aws_db_instance.postgresql.username} -d ${aws_db_instance.postgresql.db_name} -c "SELECT 1;" &>/dev/null; do
        attempt=$((attempt + 1))
        if [ $attempt -ge $max_attempts ]; then
          echo "ERROR: Database not ready after $max_attempts attempts"
          exit 1
        fi
        echo "Waiting for PostgreSQL to be ready... (attempt $attempt/$max_attempts)"
        sleep 10
      done
      
      echo "Database is ready, creating IAM user..."
      
      # Create IAM user and grant rds_iam role
      psql -h ${aws_db_instance.postgresql.endpoint} -U ${aws_db_instance.postgresql.username} -d ${aws_db_instance.postgresql.db_name} -v ON_ERROR_STOP=1 << 'EOSQL'
      DO $$
      BEGIN
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${var.db_iam_username}') THEN
          -- Create the IAM user
          EXECUTE 'CREATE USER "' || '${var.db_iam_username}' || '"';
          
          -- Grant rds_iam role (this role exists automatically in RDS PostgreSQL with IAM auth enabled)
          EXECUTE 'GRANT rds_iam TO "' || '${var.db_iam_username}' || '"';
          
          -- Grant necessary database permissions
          EXECUTE 'GRANT CONNECT ON DATABASE "' || current_database() || '" TO "' || '${var.db_iam_username}' || '"';
          
          RAISE NOTICE 'Successfully created IAM user: ${var.db_iam_username}';
        ELSE
          RAISE NOTICE 'IAM user already exists: ${var.db_iam_username}';
        END IF;
      END
      $$;
      EOSQL
      
      echo "IAM user setup completed successfully"
    EOT

    interpreter = ["bash", "-c"]
  }
}
