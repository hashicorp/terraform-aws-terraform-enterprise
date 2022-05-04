provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }
  default_tags {
    tags = var.tags
  }
}

# Random String for unique names
# ------------------------------
resource "random_string" "friendly_name" {
  length  = 4
  upper   = false
  number  = false
  special = false
}

# Keypair for SSH
# ---------------
resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  filename = "${path.module}/work/private-key.pem"

  content         = tls_private_key.main.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "main" {
  public_key = tls_private_key.main.public_key_openssh

  key_name = "${local.friendly_name_prefix}-ssh"
}

# Store TFE License as secret
# ---------------------------
module "secrets" {
  source = "../../fixtures/secrets"
  tfe_license = {
    name = "${local.friendly_name_prefix}-license"
    path = var.license_file
  }
}

# Key Management Service
# ----------------------
module "kms" {
  source    = "../../fixtures/kms"
  key_alias = "${local.friendly_name_prefix}-key"
}

# Standalone Airgapped - DEV (bootstrap prerequisites)
# ----------------------------------------------------
module "standalone_airgap_dev" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  distribution         = "ubuntu"
  friendly_name_prefix = local.friendly_name_prefix

  # Bootstrapping resources
  airgap_url                                = var.airgap_url
  tfe_license_bootstrap_airgap_package_path = "/var/lib/ptfe/ptfe.airgap"
  tls_bootstrap_cert_pathname               = "/var/lib/terraform-enterprise/certificate.pem"
  tls_bootstrap_key_pathname                = "/var/lib/terraform-enterprise/key.pem"
  tfe_license_secret_id                     = module.secrets.tfe_license_secret_id

  # Standalone, External Mode, Airgapped Installation Example
  asg_tags                    = var.tags
  iact_subnet_list            = var.iact_subnet_list
  iam_role_policy_arns        = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  instance_type               = "m5.xlarge"
  key_name                    = aws_key_pair.main.key_name
  kms_key_arn                 = module.kms.key
  load_balancing_scheme       = "PUBLIC"
  node_count                  = 1
  operational_mode            = "external"
  redis_encryption_at_rest    = false
  redis_encryption_in_transit = false
  redis_use_password_auth     = false
  tfe_subdomain               = var.tfe_subdomain
  vm_certificate_secret_id    = var.certificate_pem_secret_id
  vm_key_secret_id            = var.private_key_pem_secret_id
}