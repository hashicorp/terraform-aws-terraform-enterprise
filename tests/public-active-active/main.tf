provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }
}

resource "random_string" "friendly_name" {
  length  = 4
  upper   = false # Some AWS resources do not accept uppercase characters.
  number  = false
  special = false
}

module "public_active_active" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  friendly_name_prefix = random_string.friendly_name.id
  tfe_license_name     = "terraform-aws-terraform-enterprise.rli"

  deploy_secretsmanager        = false
  deploy_vpc                   = false
  external_bootstrap_bucket    = var.external_bootstrap_bucket
  iact_subnet_list             = var.iact_subnet_list
  instance_type                = "m5.xlarge"
  load_balancing_scheme        = "PUBLIC"
  network_id                   = var.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_private_subnets      = var.network_private_subnets
  network_public_subnets       = var.network_public_subnets
  node_count                   = 2
  redis_encryption_at_rest     = false
  redis_encryption_in_transit  = false
  redis_require_password       = false
  tfe_license_filepath         = ""
  tfe_subdomain                = "test-public-active-active"

  common_tags = {
    Terraform   = "cloud"
    Environment = "tfe_modules_test"
    Test        = "Public Active/Active"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
  }
}
