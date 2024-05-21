# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  common_tags = {
    Environment = var.license_file == null ? "tfe_utilities_test" : "ptfe-replicated CI"
    Description = "Standalone Aurora"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  friendly_name_prefix  = random_string.friendly_name.id
  load_balancing_scheme = "PUBLIC"
  registry              = "quay.io"
  test_name             = "${local.friendly_name_prefix}-test-standalone-aurora"
  ssm_policy_arn        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  utility_module_test   = var.license_file == null
}