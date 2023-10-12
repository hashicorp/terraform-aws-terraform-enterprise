# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_secretsmanager_secret" "vm_key" {
  name = "wildcard-private-key-pem"
}

data "aws_secretsmanager_secret" "vm_certificate" {
  name = "wildcard-chained-certificate-pem"
}

data "aws_ami" "rhel" {
  owners = ["309956199498"] # RedHat

  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8.6.0_HVM-20220503-x86_64-2-Hourly2-GP2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}