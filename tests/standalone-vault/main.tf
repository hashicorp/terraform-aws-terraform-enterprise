# Random string to prepend resources
# ----------------------------------
resource "random_string" "friendly_name" {
  length  = 4
  upper   = false # Some AWS resources do not accept uppercase characters.
  number  = false
  special = false
}

# Store TFE License as secret
# ---------------------------

module "secrets" {
  source = "../../fixtures/secrets"
  tfe_license = {
    name = "${local.friendly_name_prefix}-tfe-license"
    path = var.license_file
  }
}

module "hcp_vault" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//fixtures/test_hcp_vault?ref=main"

  hcp_vault_cluster_id              = local.test_name
  hcp_vault_cluster_hvn_id          = "team-tfe-dev-hvn"
  hcp_vault_cluster_public_endpoint = true
  hcp_vault_cluster_tier            = "standard_medium"

  vault_role_name   = "${local.test_name}-role"
  vault_policy_name = "dev-team"
}

# Standalone, external services with external (HCP) Vault scenario
# ----------------------------------------------------------------
module "standalone_vault" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = "tfe-team-dev.aws.ptfedev.com"
  friendly_name_prefix = local.friendly_name_prefix
  tfe_license_secret   = module.secrets.tfe_license

  iam_role_policy_arns        = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iact_subnet_list            = ["0.0.0.0/0"]
  instance_type               = "m5.xlarge"
  key_name                    = "standalone-vault"
  kms_key_alias               = local.test_name
  load_balancing_scheme       = "PUBLIC"
  node_count                  = 1
  redis_encryption_at_rest    = false
  redis_encryption_in_transit = false
  redis_require_password      = false
  tfe_subdomain               = local.friendly_name_prefix

  # Vault
  extern_vault_enable    = 1
  extern_vault_addr      = module.hcp_vault.url
  extern_vault_role_id   = module.hcp_vault.app_role_id
  extern_vault_secret_id = module.hcp_vault.app_role_secret_id
  extern_vault_namespace = "admin"

  asg_tags = local.common_tags
}
