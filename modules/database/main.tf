# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Get current AWS region
data "aws_region" "current" {}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

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

resource "aws_security_group_rule" "postgresql_ec2_ingress" {
  security_group_id        = aws_security_group.postgresql.id
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.postgresql.id
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

resource "tls_private_key" "postgres_db_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.friendly_name_prefix}-ec2-postgres-key"
  public_key = tls_private_key.postgres_db_ssh_key.public_key_openssh
}

resource "local_file" "postgres_db_private_key" {
  content         = tls_private_key.postgres_db_ssh_key.private_key_pem
  filename        = "${path.module}/${var.friendly_name_prefix}-ec2-postgres-key.pem"
  file_permission = "0600"
}

resource "aws_security_group_rule" "postgres_db_ssh_ingress" {
  security_group_id = aws_security_group.postgresql.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "postgres_db_egress" {
  security_group_id = aws_security_group.postgresql.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "postgres_db_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "m5.xlarge"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.postgresql.id]
  iam_instance_profile        = var.aws_iam_instance_profile
  key_name                    = aws_key_pair.ec2_key.key_name
  subnet_id                   = var.network_public_subnets[0]
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 100
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = "Terraform-Postgres-mTLS"
  }
}

resource "null_resource" "create_iam_db_user" {
  count = var.postgres_enable_iam_auth ? 1 : 0
  
  depends_on = [aws_db_instance.postgresql]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.postgres_db_ssh_key.private_key_pem
    host        = aws_instance.postgres_db_instance.public_ip
  }

   provisioner "file" {
    source      = "${path.module}/files/create_iam_user.sh"
    destination = "/home/ubuntu/create_iam_user.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/create_iam_user.sh",
      "sudo DB_PASSWORD='${local.fixed_password}' IAM_USERNAME=${var.db_iam_username} DB_PORT=${aws_db_instance.postgresql.port} DB_USERNAME=${var.db_username} DB_NAME=${var.db_name} DB_HOST=${aws_db_instance.postgresql.address} /home/ubuntu/create_iam_user.sh"
    ]
  }

  # Trigger recreation if database endpoint changes
  triggers = {
    database_endpoint = aws_db_instance.postgresql.address
    database_username = var.db_iam_username
  }
}
