# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  common_tags = {
    Environment = "tfe_modules_test"
    Description = "Private Active/Active"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  http_proxy_port       = 3128
  friendly_name_prefix  = random_string.friendly_name.id
  load_balancing_scheme = "PRIVATE"
  registry              = "quay.io"
  ssm_policy_arn        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  test_name             = "${local.friendly_name_prefix}-test-private-active-active"
  utility_module_test   = var.license_file == null
}
