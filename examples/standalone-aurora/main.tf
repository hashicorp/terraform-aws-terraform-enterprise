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
  source = "../../fixtures/secrets"
  tfe_license = {
    name = "${local.friendly_name_prefix}-tfe-license"
    path = var.license_file
  }
}

# Key Management Service
# ----------------------
module "kms" {
  source    = "../../fixtures/kms"
  key_alias = "${local.friendly_name_prefix}-key"
}

# Standalone with Aurora database
# -------------------------------
module "standalone_aurora" {
  source = "../../"

  acm_certificate_arn   = var.acm_certificate_arn
  domain_name           = var.domain_name
  distribution          = "ubuntu"
  friendly_name_prefix  = local.friendly_name_prefix
  tfe_license_secret_id = module.secrets.tfe_license_secret_id

  # Standalone, Aurora Database Example
  enable_aurora                         = true
  aurora_cluster_instance_replica_count = var.aurora_cluster_instance_replica_count
  aurora_cluster_instance_enable_single = var.aurora_cluster_instance_enable_single
  aurora_db_password                    = var.aurora_db_password
  aurora_db_username                    = var.aurora_db_username

  iact_subnet_list             = ["0.0.0.0/0"]
  iam_role_policy_arns         = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  instance_type                = "m5.4xlarge"
  kms_key_arn                  = module.kms.key
  load_balancing_scheme        = "PUBLIC"
  network_private_subnet_cidrs = local.network_private_subnet_cidrs
  node_count                   = 1
  operational_mode             = "external"
  redis_encryption_at_rest     = false
  redis_encryption_in_transit  = true
  redis_use_password_auth      = true
  tfe_subdomain                = local.friendly_name_prefix
  vm_certificate_secret_id     = var.certificate_pem_secret_id
  vm_key_secret_id             = var.private_key_pem_secret_id
}
