locals {
  common_tags = {
    Terraform   = "False"
    Environment = var.license_file == null ? "tfe_utilities_test" : "ptfe-replicated CI"
    Description = "Standalone Vault"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  friendly_name_prefix  = random_string.friendly_name.id
  test_name             = "${local.friendly_name_prefix}-test-standalone-vault"
  load_balancing_scheme = "PUBLIC"
  utility_module_test   = var.license_file == null
}