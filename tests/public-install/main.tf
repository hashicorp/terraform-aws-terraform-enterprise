resource "random_string" "friendly_name" {
  length  = 4
  upper   = false # Some AWS resources do not accept uppercase characters.
  number  = false
  special = false
}

module "public_install" {
  source = "../../"

  tfe_license_filepath = var.license_path
  tfe_license_name     = "replicated_license.rli"

  tfe_subdomain        = "test-public-install"
  domain_name          = var.domain_name
  friendly_name_prefix = random_string.friendly_name.id

  node_count = 2

  acm_certificate_arn = var.acm_certificate_arn

  deploy_secretsmanager = false
  deploy_bastion        = false

  # Allow traffic from public load-balancer.
  load_balancing_scheme = "PUBLIC"

  # Disable Redis encryption, TLS, and password.
  redis_encryption_in_transit = false
  redis_encryption_at_rest    = false
  redis_require_password      = false

  common_tags = {
    Terraform   = "true"
    Environment = "dev"
    Test        = "Public Install"
  }
}
