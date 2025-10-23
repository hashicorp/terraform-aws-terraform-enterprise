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

  # Enable IAM database authentication for PostgreSQL passwordless auth
  iam_database_authentication_enabled = var.enable_iam_database_authentication
}

# Create IAM database user using psql command when IAM auth is enabled
resource "null_resource" "create_iam_user" {
  count = var.enable_iam_database_authentication ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      export PGPASSWORD="${aws_db_instance.postgresql.password}"
      psql -h ${aws_db_instance.postgresql.address} \
           -p ${aws_db_instance.postgresql.port} \
           -U ${aws_db_instance.postgresql.username} \
           -d ${aws_db_instance.postgresql.db_name} \
           -c "CREATE USER \"${var.friendly_name_prefix}_iam_user\"; GRANT rds_iam TO \"${var.friendly_name_prefix}_iam_user\"; GRANT ALL PRIVILEGES ON DATABASE ${aws_db_instance.postgresql.db_name} TO \"${var.friendly_name_prefix}_iam_user\"; GRANT ALL PRIVILEGES ON SCHEMA public TO \"${var.friendly_name_prefix}_iam_user\";"
    EOT
  }

  depends_on = [aws_db_instance.postgresql]

  triggers = {
    db_instance_id = aws_db_instance.postgresql.id
    iam_user_name  = "${var.friendly_name_prefix}_iam_user"
  }
}


