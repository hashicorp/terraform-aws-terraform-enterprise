# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_string" "postgresql_password" {
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

  # Enable IAM database authentication if requested
  iam_database_authentication_enabled = var.enable_iam_database_authentication
}

# Create IAM database user when IAM authentication is enabled
resource "null_resource" "create_iam_db_user" {
  count = var.enable_iam_database_authentication ? 1 : 0

  triggers = {
    db_instance_id = aws_db_instance.postgresql.id
    iam_user_name  = "${var.friendly_name_prefix}-iam-user"
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "Creating IAM database user for RDS instance ${aws_db_instance.postgresql.id}"
      
      # Wait for RDS instance to be available
      aws rds wait db-instance-available --db-instance-identifier ${aws_db_instance.postgresql.id} --region ${data.aws_region.current.name}
      
      # Get the endpoint without port
      DB_HOST=$(echo "${aws_db_instance.postgresql.endpoint}" | cut -d: -f1)
      
      # Create IAM database user using psql
      export PGPASSWORD="${random_string.postgresql_password.result}"
      psql -h "$DB_HOST" -U "${var.db_username}" -d "${var.db_name}" -p 5432 -c "
        DO \$\$
        BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${var.friendly_name_prefix}-iam-user') THEN
            CREATE USER \"${var.friendly_name_prefix}-iam-user\";
            GRANT rds_iam TO \"${var.friendly_name_prefix}-iam-user\";
            GRANT ALL PRIVILEGES ON DATABASE \"${var.db_name}\" TO \"${var.friendly_name_prefix}-iam-user\";
            GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"${var.friendly_name_prefix}-iam-user\";
            GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"${var.friendly_name_prefix}-iam-user\";
            ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"${var.friendly_name_prefix}-iam-user\";
            ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"${var.friendly_name_prefix}-iam-user\";
            RAISE NOTICE 'IAM user ${var.friendly_name_prefix}-iam-user created successfully';
          ELSE
            RAISE NOTICE 'IAM user ${var.friendly_name_prefix}-iam-user already exists';
          END IF;
        END
        \$\$;
      "
      echo "IAM database user creation completed"
    EOT
    
    on_failure = continue
  }

  depends_on = [aws_db_instance.postgresql]
}

data "aws_region" "current" {}
