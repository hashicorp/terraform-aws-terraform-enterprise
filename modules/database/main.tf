# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_string" "postgresql_password" {
  length  = 128
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



module "rds_aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name           = "test-aurora-db-postgres96"
  engine         = "aurora-postgresql"
  engine_version = "14.5"
  instance_class = "db.r6g.large"
  instances = {
    one = {}
    2 = {
      instance_class = "db.r6g.2xlarge"
    }
  }
  master_username = "tfe"
  master_password          = random_string.postgresql_password.result
  vpc_id               = var.network_id
  db_subnet_group_name = aws_db_subnet_group.tfe.name
  security_group_rules = {
    ex1_ingress = {
      cidr_blocks = var.network_private_subnet_cidrs
    }
    ex1_ingress = {
      source_security_group_id = aws_security_group.postgresql.id
    }
  }

  skip_final_snapshot = true
  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

#  source  = "terraform-aws-modules/rds-aurora/aws"
#  version = "~> 8.5.0"
#
#  name           = "test-aurora-db-postgres96"
#  engine         = "aurora-postgresql"
#  engine_version = "14"
#  instance_class  = "db.r5.large"
#
#  master_username = "csteinmeyer"
#  master_password = "password1234"
#  create_db_parameter_group = false
#  db_parameter_group_name         = "default"
#  db_cluster_parameter_group_name = "default"
#  db_parameter_group_family = "aurora-postgresql14"
#
#  vpc_id  = var.network_id
#  db_subnet_group_name        = aws_db_subnet_group.tfe.name
#
#  autoscaling_enabled           = true
#  
#  security_group_rules = true ? {
#    vpc_ingress = {
#      cidr_blocks = var.network_private_subnet_cidrs
#    }
#  } : null
#
#  vpc_security_group_ids = [aws_security_group.postgresql.id]
#
#  storage_encrypted   = true
#  apply_immediately   = true
#  monitoring_interval = 10
#
#
#  enabled_cloudwatch_logs_exports = ["postgresql"]
#
#  tags = {
#    Environment = "dev"
#    Terraform   = "true"
#    ok_to_terminate   = "true"
#    User   = "csteinmeyer"
#  }
#}

#resource "aws_db_instance" "postgresql" {
#  allocated_storage = 20
#  engine            = "postgres"
#  instance_class    = var.db_size
#  password          = random_string.postgresql_password.result
#  # no special characters allowed
#  username = var.db_username
#
#  allow_major_version_upgrade = false
#  apply_immediately           = true
#  auto_minor_version_upgrade  = true
#  backup_retention_period     = var.db_backup_retention
#  backup_window               = var.db_backup_window
#  db_subnet_group_name        = aws_db_subnet_group.tfe.name
#  delete_automated_backups    = true
#  deletion_protection         = false
#  engine_version              = var.engine_version
#  identifier_prefix           = "${var.friendly_name_prefix}-tfe"
#  max_allocated_storage       = 0
#  multi_az                    = true
#  # no special characters allowed
#  db_name                = var.db_name
#  port                   = 5432
#  publicly_accessible    = false
#  skip_final_snapshot    = true
#  storage_encrypted      = true
#  kms_key_id             = var.kms_key_arn
#  storage_type           = "gp2"
#  vpc_security_group_ids = [aws_security_group.postgresql.id]
#}
#