# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Random String for unique names
# ------------------------------
resource "random_string" "friendly_name" {
  length  = 4
  upper   = false
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

# Standalone, mounted disk
# ------------------------
module "standalone" {
  source = "../../"

  operational_mode    = "disk"
  acm_certificate_arn = var.acm_certificate_arn
  domain_name         = var.domain_name
  distribution        = "amazon-linux-2023"
  ami_id              = data.aws_ami.amazon_linux_2023.id

  bypass_preflight_checks   = true
  health_check_grace_period = 3000
  asg_tags                  = local.common_tags
  disk_path                 = "/opt/hashicorp/data"
  friendly_name_prefix      = local.friendly_name_prefix
  tfe_license_secret_id     = module.secrets.tfe_license_secret_id
  iam_role_policy_arns      = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iact_subnet_list          = ["0.0.0.0/0"]
  instance_type             = "m5.xlarge"
  key_name                  = "standalone-mounted-amazon-linux-2023"
  kms_key_arn               = module.kms.key
  load_balancing_scheme     = local.load_balancing_scheme
  node_count                = 1
  tfe_subdomain             = local.friendly_name_prefix
  vm_certificate_secret_id  = data.aws_secretsmanager_secret.vm_certificate.id
  vm_key_secret_id          = data.aws_secretsmanager_secret.vm_key.id
}
