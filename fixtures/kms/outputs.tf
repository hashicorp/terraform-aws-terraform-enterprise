# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "key" {
  value = aws_kms_key.main.arn

  description = "The KMS key used to encrypt data."
}

