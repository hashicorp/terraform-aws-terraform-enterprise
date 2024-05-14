# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  common_tags = {
    Environment = "tfe_modules_test"
    Description = "Standalone, mounted disk, Amazon Linux 2023"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  friendly_name_prefix  = random_string.friendly_name.id
  load_balancing_scheme = "PUBLIC"
}
