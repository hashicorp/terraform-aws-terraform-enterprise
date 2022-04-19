provider "aws" {

  region = "us-east-2"

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

locals {
  friendly_name_prefix = random_string.friendly_name.id
}

# KMS key used to encrypt data
# ----------------------------
module "kms" {
  source    = "../../fixtures/kms"
  key_alias = "${local.friendly_name_prefix}-key"
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

  key_name = "${var.friendly_name_prefix}-ssh"
}

# Run TFE root module for Standalone Airgapped External Mode
# ----------------------------------------------------------
module "standalone_airgap" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  distribution         = "ubuntu"
  friendly_name_prefix = local.friendly_name_prefix


  # Bootstrapping resources
  tfe_license_bootstrap_airgap_package_path = "/var/lib/ptfe/ptfe.airgap"
  tls_bootstrap_cert_pathname               = "/var/lib/terraform-enterprise/certificate.pem"
  tls_bootstrap_key_pathname                = "/var/lib/terraform-enterprise/key.pem"
  tfe_license_secret_id                     = null

  # Standalone, External Mode, Airgapped Installation Example
  ami_id                      = local.ami_id
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
}