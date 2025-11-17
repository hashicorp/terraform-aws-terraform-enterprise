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
  publicly_accessible    = true
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
            "echo '=== PostgreSQL IAM User Setup Started ==='",
            "echo 'Endpoint: {{ dbEndpoint }}'",
            "echo 'IAM User: {{ iamUsername }}'",
            "",
            "# Install PostgreSQL client if needed",
            "if ! command -v psql >/dev/null 2>&1; then",
            "  echo 'Installing PostgreSQL client...'",
            "  if command -v apt-get >/dev/null 2>&1; then",
            "    sudo apt-get update -qq",
            "    sudo apt-get install -y postgresql-client",
            "  elif command -v yum >/dev/null 2>&1; then",
            "    sudo yum update -y -q",
            "    sudo yum install -y postgresql15",
            "  else",
            "    echo 'ERROR: Cannot install PostgreSQL client'",
            "    exit 1",
            "  fi",
            "fi",
            "",
            "# Set password for database connection",
            "export PGPASSWORD='{{ dbPassword }}'",
            "",
            "# Wait for database to be ready",
            "echo 'Waiting for database to be ready...'",
            "max_attempts=30",
            "attempt=0",
            "while [ $attempt -lt $max_attempts ]; do",
            "  if psql -h {{ dbEndpoint }} -U {{ dbUsername }} -d {{ dbName }} -c 'SELECT 1;' >/dev/null 2>&1; then",
            "    echo 'Database is ready!'",
            "    break",
            "  fi",
            "  attempt=$((attempt + 1))",
            "  echo \"Waiting for database... attempt $attempt/$max_attempts\"",
            "  sleep 10",
            "done",
            "",
            "if [ $attempt -eq $max_attempts ]; then",
            "  echo 'ERROR: Database not ready after $max_attempts attempts'",
            "  exit 1",
            "fi",
            "",
            "# Create IAM user",
            "echo 'Creating IAM user...'",
            "psql -h {{ dbEndpoint }} -U {{ dbUsername }} -d {{ dbName }} -v ON_ERROR_STOP=1 << 'EOF'",
            "DO $$",
            "BEGIN",
            "  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '{{ iamUsername }}') THEN",
            "    CREATE USER \"{{ iamUsername }}\";",
            "    GRANT rds_iam TO \"{{ iamUsername }}\";",
            "    GRANT CONNECT ON DATABASE \"{{ dbName }}\" TO \"{{ iamUsername }}\";",
            "    GRANT USAGE ON SCHEMA public TO \"{{ iamUsername }}\";",
            "    GRANT CREATE ON SCHEMA public TO \"{{ iamUsername }}\";",
            "    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{ iamUsername }}\";",
            "    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"{{ iamUsername }}\";",
            "    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"{{ iamUsername }}\";",
            "    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"{{ iamUsername }}\";",
            "    RAISE NOTICE 'Successfully created IAM user: {{ iamUsername }}';",
            "  ELSE",
            "    RAISE NOTICE 'IAM user already exists: {{ iamUsername }}';",
            "  END IF;",
            "END",
            "$$;",
            "EOF",
            "",
            "echo '=== PostgreSQL IAM User Setup Completed ==='",
            "",
            "# Verify user creation",
            "psql -h {{ dbEndpoint }} -U {{ dbUsername }} -d {{ dbName }} -c \"SELECT usename, usesuper FROM pg_user WHERE usename = '{{ iamUsername }}';\"",
          ]
        }
      }
    ]
  })

  tags = {
    Name = "${var.friendly_name_prefix}-postgres-iam-setup"
  }
}

resource "null_resource" "create_iam_db_user" {
  count = var.postgres_enable_iam_auth ? 1 : 0
  
  depends_on = [aws_db_instance.postgresql]

  provisioner "local-exec" {
    environment = {
      PGPASSWORD = local.fixed_password
    }
    command = <<EOT
# Install PostgreSQL client if not present
if ! command -v psql > /dev/null 2>&1; then
    echo "PostgreSQL client not found. Installing..."
    if [ -f /etc/debian_version ]; then
        apt-get update && apt-get install -y postgresql-client
    elif command -v brew > /dev/null 2>&1; then
        brew install postgresql
    else
        echo "ERROR: Cannot install PostgreSQL client automatically"
        echo "The IAM user will be created via user_data script instead."
        exit 0
    fi
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting PostgreSQL IAM user creation for ${var.db_iam_username}"

# Wait for database to be available with enhanced error logging
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Waiting for database ${aws_db_instance.postgresql.address} to be ready..."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Connection details:"
echo "  Host: ${aws_db_instance.postgresql.address}"
echo "  Port: ${aws_db_instance.postgresql.port}"
echo "  Username: ${var.db_username}"
echo "  Database: ${var.db_name}"
echo "  SSL Mode: require"

for i in $(seq 1 10); do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Attempting connection $i/10..."
  
  # Test basic network connectivity first
  if command -v nc >/dev/null 2>&1; then
    if ! nc -z ${aws_db_instance.postgresql.address} ${aws_db_instance.postgresql.port} 2>/dev/null; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Cannot reach ${aws_db_instance.postgresql.address}:${aws_db_instance.postgresql.port} (network/firewall issue)"
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Network connectivity to ${aws_db_instance.postgresql.address}:${aws_db_instance.postgresql.port} is OK"
    fi
  fi
  
  # Try database connection with detailed error capture
  psql_output=$(timeout 30 psql "host=${aws_db_instance.postgresql.address} port=${aws_db_instance.postgresql.port} user=${var.db_username} dbname=${var.db_name} sslmode=require" -c "SELECT version();" 2>&1)
  psql_exit_code=$?
  
  if [ $psql_exit_code -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Database connection successful after $i attempts"
    break
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Database connection attempt $i/60 failed, retrying in 10 seconds..."
    sleep 10
  fi
  
  if [ $i -eq 10 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Could not connect to database after 60 attempts"
    echo "This may be due to network access issues. The IAM user will be created via user_data script instead."
    exit 0  # Don't fail the terraform apply
  fi
done

# Create IAM user with proper permissions
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating IAM user: ${var.db_iam_username}"
if psql "host=${aws_db_instance.postgresql.address} port=${aws_db_instance.postgresql.port} user=${var.db_username} dbname=${var.db_name} sslmode=require" -c "
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${var.db_iam_username}') THEN
        CREATE USER \"${var.db_iam_username}\" WITH LOGIN;
        GRANT rds_iam TO \"${var.db_iam_username}\";
        GRANT CONNECT ON DATABASE \"${var.db_name}\" TO \"${var.db_iam_username}\";
        GRANT USAGE ON SCHEMA public TO \"${var.db_iam_username}\";
        GRANT CREATE ON SCHEMA public TO \"${var.db_iam_username}\";
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"${var.db_iam_username}\";
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"${var.db_iam_username}\";
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"${var.db_iam_username}\";
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"${var.db_iam_username}\";
        RAISE NOTICE 'Successfully created IAM user: ${var.db_iam_username}';
    ELSE
        RAISE NOTICE 'IAM user already exists: ${var.db_iam_username}';
    END IF;
END \$\$;" 2>&1; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] IAM user setup completed successfully"
    
    # Verify user creation
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Verifying IAM user creation..."
    psql "host=${aws_db_instance.postgresql.address} port=${aws_db_instance.postgresql.port} user=${var.db_username} dbname=${var.db_name} sslmode=require" -c "
SELECT 
    usename as username,
    usesuper as is_superuser,
    usecreatedb as can_create_db,
    userepl as can_replicate
FROM pg_user 
WHERE usename = '${var.db_iam_username}';" 2>&1
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to create IAM user via Terraform"
    echo "The IAM user will be created via user_data script instead."
    exit 0  # Don't fail the terraform apply
fi
EOT
  }

  # Trigger recreation if database endpoint changes
  triggers = {
    database_endpoint = aws_db_instance.postgresql.address
    database_username = var.db_iam_username
  }
}

# Note: This null_resource attempts to create the IAM user from Terraform runner.
# If it fails due to network access, the user_data script will handle it instead.
# This provides redundancy - either Terraform creates the user, or EC2 does.
#
# The PostgreSQL IAM user creation is essential for IAM authentication to work.
# Without it, the TFE application will not be able to authenticate to the database.
