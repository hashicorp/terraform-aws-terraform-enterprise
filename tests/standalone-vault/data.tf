# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_secretsmanager_secret" "vm_key" {
  name = "wildcard-private-key-pem"
}

data "aws_secretsmanager_secret" "vm_certificate" {
  name = "wildcard-chained-certificate-pem"
}
