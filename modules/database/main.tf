resource "random_string" "postgresql_password" {
  length  = 128
  special = false
}

resource "aws_security_group" "postgresql" {
  description = "The security group of the PostgreSQL deployment for TFE."
  name        = "${var.friendly_name_prefix}-tfe-postgresql"
  vpc_id      = var.network_id
  tags        = var.tags
}

resource "aws_security_group_rule" "postgresql_tfe_ingress" {
  security_group_id        = aws_security_group.postgresql.id
  description              = "Inbound traffic to postgresql port from TFE"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.tfe_instance_sg
}

resource "aws_security_group_rule" "postgresql_tfe_egress" {
  security_group_id        = aws_security_group.postgresql.id
  description              = "Outbound ICMP traffic from RDS"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.tfe_instance_sg
}

resource "aws_security_group_rule" "postgresql_ingress" {
  security_group_id = aws_security_group.postgresql.id
  description       = "Inbound traffic to postgresql port from VPC"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.network_private_subnet_cidrs
}

resource "aws_security_group_rule" "postgresql_egress" {
  security_group_id = aws_security_group.postgresql.id
  description       = "Outbound traffic from postgresql port to VPC"
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
  #checkov:skip=CKV_AWS_129:We allow enabling this, but it's not on by default so skip the check.
  allocated_storage = 20
  engine            = "postgres"
  instance_class    = var.db_size
  password          = random_string.postgresql_password.result
  # no special characters allowed
  username = "espdtfe"

  iam_database_authentication_enabled = true
  allow_major_version_upgrade         = false
  apply_immediately                   = true
  auto_minor_version_upgrade          = true
  backup_retention_period             = var.db_backup_retention
  backup_window                       = var.db_backup_window
  db_subnet_group_name                = aws_db_subnet_group.tfe.name
  delete_automated_backups            = true
  deletion_protection                 = false
  engine_version                      = var.engine_version
  identifier_prefix                   = "${var.friendly_name_prefix}-tfe"
  max_allocated_storage               = 0
  multi_az                            = true
  monitoring_interval                 = var.monitoring_interval
  # no special characters allowed
  name                            = "espdtfe"
  port                            = 5432
  publicly_accessible             = false
  skip_final_snapshot             = true
  storage_encrypted               = true
  storage_type                    = "gp2"
  vpc_security_group_ids          = [aws_security_group.postgresql.id]
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs
  tags                            = var.tags
}
