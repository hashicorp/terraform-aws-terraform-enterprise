# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#################################################
# AZs
#################################################
data "aws_availability_zones" "available" {
  state = "available"

}

resource "random_string" "postgresql_password" {
  length  = 99
  special = false
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


################################################################################
# RDS Aurora Cluster and Instances
################################################################################

resource "aws_rds_cluster" "aurora_postgresql" {

  allow_major_version_upgrade = false
  apply_immediately           = true
  availability_zones          = slice(data.aws_availability_zones.available.names, 0, 3)

  cluster_identifier = "${var.friendly_name_prefix}-tfe"
  cluster_members    = var.cluster_members
  # no special characters allowed
  database_name            = var.db_name
  db_subnet_group_name     = aws_db_subnet_group.tfe.name
  delete_automated_backups = true
  backup_retention_period  = var.db_backup_retention
  deletion_protection      = false
  engine                   = "aurora-postgresql"
  engine_version           = var.engine_version

  kms_key_id      = var.kms_key_id
  master_password = random_string.postgresql_password.result
  # no special characters allowed
  master_username              = var.db_username
  port                         = 5432
  preferred_backup_window      = var.db_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window


  skip_final_snapshot = true
  storage_encrypted   = true

  vpc_security_group_ids = [aws_security_group.postgresql.id]
}

resource "aws_rds_cluster_instance" "cluster_instance_0" {
  count              = var.single_instance_enabled ? 1 : 0
  identifier         = format("%s-aurora-node-0", "${var.friendly_name_prefix}-tfe")
  cluster_identifier = aws_rds_cluster.aurora_postgresql.id
  instance_class     = var.db_size
  engine             = aws_rds_cluster.aurora_postgresql.engine
  engine_version     = aws_rds_cluster.aurora_postgresql.engine_version
}

resource "aws_rds_cluster_instance" "cluster_instances_n" {
  depends_on         = [aws_rds_cluster_instance.cluster_instance_0]
  count              = var.single_instance_enabled ? var.replica_count : 0
  identifier         = format("%s-aurora-node-%d", "${var.friendly_name_prefix}-tfe", count.index + 1)
  cluster_identifier = aws_rds_cluster.aurora_postgresql.id
  instance_class     = var.db_size
  engine             = aws_rds_cluster.aurora_postgresql.engine
  engine_version     = aws_rds_cluster.aurora_postgresql.engine_version
}
