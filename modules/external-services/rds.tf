locals {
  postgres_port = "5432"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "rds" {
  vpc_id = var.vpc_id
  tags   = var.rds_subnet_tags
}

data "aws_subnet" "selected" {
  count = length(data.aws_subnet_ids.rds.ids)
  id    = data.aws_subnet_ids.rds.ids[count.index]
}

resource "aws_security_group" "db_access" {
  description = "allow instances to talk to each other, and have unfettered egress"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = local.postgres_port
    to_port   = local.postgres_port

    cidr_blocks = [data.aws_subnet.selected.*.cidr_block]
  }
}

resource "random_string" "database_password" {
  length  = 40
  special = false
}

resource "aws_db_subnet_group" "tfe" {
  name_prefix = "${var.prefix}tfe-${var.install_id}"
  subnet_ids  = [data.aws_subnet.selected.*.id]

  tags = {
    Name = "tfe subnet group"
  }
}

resource "aws_rds_cluster" "tfe" {
  cluster_identifier_prefix = "${var.prefix}tfe-${var.install_id}"
  engine                    = "aurora-postgresql"
  database_name             = var.database_name
  master_username           = var.database_username
  master_password           = random_string.database_password.result
  db_subnet_group_name      = aws_db_subnet_group.tfe.name
  backup_retention_period   = 5
  preferred_backup_window   = "07:00-09:00"
  vpc_security_group_ids    = [aws_security_group.db_access.id]
  final_snapshot_identifier = "${var.prefix}tfe-${var.install_id}-final"
}

resource "aws_rds_cluster_instance" "tfe1" {
  apply_immediately    = true
  cluster_identifier   = aws_rds_cluster.tfe.id
  identifier_prefix    = "${var.prefix}tfe1"
  engine               = "aurora-postgresql"
  instance_class       = "db.r5.large"
  db_subnet_group_name = aws_db_subnet_group.tfe.name
}
