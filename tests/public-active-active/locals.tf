locals {
  common_tags = {
    Terraform   = "cloud"
    Environment = "tfe_modules_test"
    Description = "Public Active/Active"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
  }
}
