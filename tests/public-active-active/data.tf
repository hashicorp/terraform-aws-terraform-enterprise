# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_secretsmanager_secret" "vm_key" {
  name = "wildcard-private-key-pem"
}

data "aws_secretsmanager_secret" "vm_certificate" {
  name = "wildcard-chained-certificate-pem"
}
