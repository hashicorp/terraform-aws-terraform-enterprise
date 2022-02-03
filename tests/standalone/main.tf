provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }

  default_tags {
    tags = local.common_tags
  }
}

# Random string to prepend resources
# ----------------------------------
resource "random_string" "friendly_name" {
  length  = 4
  upper   = false # Some AWS resources do not accept uppercase characters.
  number  = false
  special = false
}

# Keypair for SSH
# ----------------------------------
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
    name = "${local.friendly_name_prefix}-tfe-license"
    path = var.license_file
  }
}
# Standalone, mounted disk
# ------------------------
module "standalone" {
  source = "../../"

  operational_mode    = "disk"
  acm_certificate_arn = var.acm_certificate_arn
  domain_name         = var.domain_name

  friendly_name_prefix        = local.friendly_name_prefix
  tfe_license_secret          = module.secrets.tfe_license
  redis_encryption_at_rest    = false
  redis_encryption_in_transit = false
  redis_require_password      = false
  iam_role_policy_arns        = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iact_subnet_list            = ["0.0.0.0/0"]
  instance_type               = "m5.xlarge"
  key_name                    = aws_key_pair.main.key_name
  kms_key_alias               = local.test_name
  load_balancing_scheme       = "PUBLIC"
  node_count                  = 1
  tfe_subdomain               = local.friendly_name_prefix
  asg_tags                    = local.common_tags
}
