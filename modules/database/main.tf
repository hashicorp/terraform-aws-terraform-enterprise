# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Get current AWS region
data "aws_region" "current" {}

# Use a fixed password for testing/development to enable direct database access
locals {
  # For release tests, use a fixed password to allow manual IAM user setup
  fixed_password = "password"
}

resource "random_string" "postgresql_password" {
  # Use fixed password for testing to enable direct database access
  length  = 8
  special = false
  upper   = false 
  numeric = false
  
  # Override with fixed value - this ensures consistent password for testing
  keepers = {
    password = local.fixed_password
  }
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
  # Use fixed password for testing to enable direct database access for IAM user setup
  password          = local.fixed_password
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

# Database user setup for IAM authentication - Using SSM Run Command approach
# This creates an SSM document that can be executed on EC2 instances with proper credentials
resource "aws_ssm_document" "postgres_iam_user_setup" {
  count         = var.postgres_enable_iam_auth && var.db_iam_username != "" ? 1 : 0
  name          = "${var.friendly_name_prefix}-postgres-iam-user-setup"
  document_type = "Command"
  document_format = "YAML"
  
  content = yamlencode({
    schemaVersion = "2.2"
    description   = "Create PostgreSQL IAM user for RDS IAM authentication"
    parameters = {
      dbEndpoint = {
        type        = "String"
        description = "PostgreSQL RDS endpoint"
        default     = aws_db_instance.postgresql.endpoint
      }
      dbUsername = {
        type        = "String"
        description = "PostgreSQL master username"
        default     = aws_db_instance.postgresql.username
      }
      dbName = {
        type        = "String"
        description = "PostgreSQL database name"
        default     = aws_db_instance.postgresql.db_name
      }
      iamUsername = {
        type        = "String"
        description = "IAM username to create in PostgreSQL"
        default     = var.db_iam_username
      }
      dbPassword = {
        type        = "String"
        description = "PostgreSQL master password"
        default     = local.fixed_password
      }
    }
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "setupPostgresIAMUser"
        inputs = {
          timeoutSeconds = "300"
          runCommand = [
            "#!/bin/bash",
            "set -e",
            "echo '=== PostgreSQL IAM User Setup ==='",
            "# Install PostgreSQL client",
            "if ! command -v psql &> /dev/null; then",
            "  if command -v apt-get &> /dev/null; then",
            "    sudo apt-get update && sudo apt-get install -y postgresql-client",
            "  else",
            "    sudo yum update -y && sudo yum install -y postgresql15",
            "  fi",
            "fi",
            "export PGPASSWORD='{{ dbPassword }}'",
            "# Wait for database",
            "for i in {1..30}; do",
            "  psql -h {{ dbEndpoint }} -U {{ dbUsername }} -d {{ dbName }} -c 'SELECT 1;' &>/dev/null && break",
            "  echo \"Waiting for DB... ($i/30)\" && sleep 10",
            "done",
            "# Create IAM user",
            "psql -h {{ dbEndpoint }} -U {{ dbUsername }} -d {{ dbName }} -v ON_ERROR_STOP=1 << 'EOSQL'",
            "DO $$",
            "BEGIN",
            "  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '{{ iamUsername }}') THEN",
            "    CREATE USER \"{{ iamUsername }}\";",
            "    GRANT rds_iam TO \"{{ iamUsername }}\";",
            "    GRANT CONNECT ON DATABASE \"{{ dbName }}\" TO \"{{ iamUsername }}\";",
            "    GRANT USAGE ON SCHEMA public TO \"{{ iamUsername }}\";",
            "    GRANT CREATE ON SCHEMA public TO \"{{ iamUsername }}\";",
            "    RAISE NOTICE 'Created IAM user: {{ iamUsername }}';",
            "  ELSE",
            "    RAISE NOTICE 'IAM user exists: {{ iamUsername }}';",
            "  END IF;",
            "END",
            "$$;",
            "EOSQL",
            "echo '=== Setup Complete ==='",
          ]
        }
      }
    ]
  })

  tags = {
    Name = "${var.friendly_name_prefix}-postgres-iam-setup"
  }
}

# Note: For PostgreSQL IAM authentication to work, we need to either:
# 1. Create the IAM user in PostgreSQL after the instance is running, OR
# 2. Use the EC2 instance to create the user via user-data script
# 
# The SSM document approach above is available but requires manual execution.
# For automated setup, this would need to be integrated into the VM module's user_data.
#
# The PostgreSQL IAM user creation is essential for IAM authentication to work.
# Without it, the TFE application will not be able to authenticate to the database.
#
# Current status: SSM document created for manual/scripted execution.
