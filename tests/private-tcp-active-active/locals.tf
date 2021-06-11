locals {
  http_proxy_port = 3128

  common_tags = {
    Terraform   = "cloud"
    Environment = local.test_name
    Description = "Private TCP Active/Active"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  friendly_name_prefix = random_string.friendly_name.id
  test_name            = "${local.friendly_name_prefix}-test-private-tcp-active-active"
}
