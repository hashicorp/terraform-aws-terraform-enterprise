# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  external_aws_configs = {

    aws_instance_profile = {
      value = var.aws_access_key_id == null ? "1" : "0"
    }

    aws_access_key_id = {
      value = var.aws_access_key_id
    }

    aws_secret_access_key = {
      value = var.aws_secret_access_key
    }

    s3_endpoint = {
      value = var.s3_endpoint
    }

    s3_bucket = {
      value = var.s3_bucket
    }

    s3_region = {
      value = var.s3_region
    }

    s3_sse = {
      value = var.s3_sse
    }

    s3_sse_kms_key_id = {
      value = var.s3_sse_kms_key_id
    }
  }
}