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
resource "aws_secretsmanager_secret" "tfe_license" {
  description = "TFE license."
}

resource "aws_secretsmanager_secret_version" "tfe_license" {
  secret_binary = filebase64(var.license_file)
  secret_id     = aws_secretsmanager_secret.tfe_license.id
}

# Standalone, external services with external (HCP) Vault scenario
# ---------------------------------------------------------------- 
module "standalone_vault" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = "tfe-team-dev.aws.ptfedev.com"
  friendly_name_prefix = local.friendly_name_prefix
  tfe_license_secret   = aws_secretsmanager_secret.tfe_license

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
  extern_vault_addr      = hcp_vault_cluster.test.vault_public_endpoint_url
  extern_vault_role_id   = vault_approle_auth_backend_role.approle.role_id
  extern_vault_secret_id = vault_approle_auth_backend_role_secret_id.approle.secret_id
  extern_vault_namespace = "admin"

  asg_tags = local.common_tags
}
