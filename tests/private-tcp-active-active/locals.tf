locals {
  complete_prefix = "${var.prefix}-${random_string.friendly_name.result}"
  http_proxy_port = 3128

  common_tags = {
    Terraform   = "cloud"
    Environment = "tfe_modules_test"
    Description = "Private TCP Active/Active"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
  }
}
