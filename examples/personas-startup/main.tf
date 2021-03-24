resource "random_pet" "subdomain" {
  length    = 2
  separator = "-"
  prefix    = var.prefix
}

resource "random_string" "friendly_name" {
  length  = 4
  upper   = false # Some AWS resources do not accept uppercase characters.
  number  = false
  special = false
}

locals {
  complete_prefix = "${var.prefix}-${random_string.friendly_name.result}"
}

module "startup_deployment" {
  source = "../../"

  tfe_license_filepath = var.license_path
  tfe_license_name     = "replicated_license.rli"

  tfe_subdomain = (var.tfe_subdomain == null) ? random_pet.subdomain.id : var.tfe_subdomain
  domain_name   = var.domain_name

  friendly_name_prefix = local.complete_prefix

  node_count = 2

  deploy_secretsmanager = false

  acm_certificate_arn = var.acm_certificate_arn

  deploy_bastion  = true
  bastion_keypair = var.existing_aws_keypair

  # Allow traffic from public load-balancer.
  load_balancing_scheme = "PUBLIC"

  # Disable Redis encryption, TLS, and password.
  redis_encryption_in_transit = false
  redis_encryption_at_rest    = false
  redis_require_password      = false
}
