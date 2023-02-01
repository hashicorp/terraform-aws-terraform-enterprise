# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "s3_bucket" {
  value = aws_s3_bucket.tfe_data_bucket

  description = "The S3 bucket which contains TFE runtime data."
}
