# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  common_tags = {
    Terraform   = "cloud"
    Environment = "tfe_modules_test"
    Description = local.test_name
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  friendly_name_prefix  = random_string.friendly_name.id
  test_name             = "${local.friendly_name_prefix}-test-public-active-active"
  load_balancing_scheme = "PUBLIC"
  utility_module_test   = var.license_file == null
}
