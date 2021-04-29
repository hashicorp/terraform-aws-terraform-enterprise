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

module "public_install" {
  source = "../../"

  tfe_license_filepath      = ""
  external_bootstrap_bucket = var.external_bootstrap_bucket
  tfe_license_name          = "terraform-aws-terraform-enterprise-public-install.rli"

  tfe_subdomain        = "test-public-install"
  domain_name          = var.domain_name
  friendly_name_prefix = random_string.friendly_name.id

  node_count = 2

  acm_certificate_arn = var.acm_certificate_arn

  deploy_secretsmanager = false
  deploy_bastion        = false

  deploy_vpc                   = false
  network_id                   = var.network_id
  network_public_subnets       = var.network_public_subnets
  network_private_subnets      = var.network_private_subnets
  network_private_subnet_cidrs = var.network_private_subnet_cidrs

  # Allow traffic from public load-balancer.
  load_balancing_scheme = "PUBLIC"

  # Disable Redis encryption, TLS, and password.
  redis_encryption_in_transit = false
  redis_encryption_at_rest    = false
  redis_require_password      = false

  iact_subnet_list = var.iact_subnet_list

  common_tags = {
    Terraform   = "cloud"
    Environment = "tfe_modules_test"
    Test        = "Public Install"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
  }
}
