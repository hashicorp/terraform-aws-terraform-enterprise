# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Random string to prepend resources
# ----------------------------------
resource "random_string" "friendly_name" {
  length  = 4
  upper   = false # Some AWS resources do not accept uppercase characters.
  numeric = false
  special = false
}

# Store TFE License as secret
# ---------------------------
module "secrets" {
  count  = local.utility_module_test || !var.is_replicated_deployment ? 0 : 1
  source = "../../fixtures/secrets"

  tfe_license = {
    name = "${local.friendly_name_prefix}-tfe-license"
    path = var.license_file
  }
}

module "kms" {
  source    = "../../fixtures/kms"
  key_alias = "${local.friendly_name_prefix}-key"
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

  acm_certificate_arn   = var.acm_certificate_arn
  disk_path             = "/opt/hashicorp/data"
  domain_name           = var.domain_name
  friendly_name_prefix  = local.friendly_name_prefix
  tfe_license_secret_id = try(module.secrets[0].tfe_license_secret_id, var.tfe_license_secret_id)
  distribution          = "ubuntu"

  bypass_preflight_checks     = true
  health_check_grace_period   = 3000
  iam_role_policy_arns        = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iact_subnet_list            = ["0.0.0.0/0"]
  instance_type               = "m5.xlarge"
  key_name                    = local.utility_module_test ? var.key_name : "standalone-vault"
  kms_key_arn                 = module.kms.key
  load_balancing_scheme       = local.load_balancing_scheme
  node_count                  = 1
  operational_mode            = "disk"
  redis_encryption_at_rest    = true
  redis_encryption_in_transit = false
  redis_use_password_auth     = false
  tfe_subdomain               = local.friendly_name_prefix
  vm_certificate_secret_id    = data.aws_secretsmanager_secret.vm_certificate.id
  vm_key_secret_id            = data.aws_secretsmanager_secret.vm_key.id

  # Vault
  extern_vault_enable    = true
  extern_vault_addr      = module.hcp_vault.url
  extern_vault_role_id   = module.hcp_vault.app_role_id
  extern_vault_secret_id = module.hcp_vault.app_role_secret_id
  extern_vault_namespace = "admin"

  asg_tags = local.common_tags

  # FDO Specific Values
  is_replicated_deployment  = var.is_replicated_deployment
  hc_license                = var.hc_license
  license_reporting_opt_out = true
  registry                  = local.registry
  registry_password         = var.registry_password
  registry_username         = var.registry_username
  tfe_image                 = "${local.registry}/hashicorp/terraform-enterprise:${var.tfe_image_tag}"
}
