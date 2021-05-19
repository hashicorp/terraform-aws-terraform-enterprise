locals {
  common_tags = {
    Terraform   = "cloud"
    Environment = "tfe_modules_test"
    Test        = "Private Active/Active"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
  }
}
