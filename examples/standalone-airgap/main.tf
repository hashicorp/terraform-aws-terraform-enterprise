provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }

  default_tags {
    tags = var.tags
  }
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

# Store TFE License as secret
# ---------------------------

module "secrets" {
  source = "../../fixtures/secrets"
  tfe_license = {
    name = "${var.friendly_name_prefix}-license"
    path = var.license_file
  }
}
# Standalone Airgapped
# --------------------
module "standalone_airgap" {
  source = "../../"

  operational_mode    = "external"
  acm_certificate_arn = var.acm_certificate_arn
  domain_name         = var.domain_name

  airgap_url                  = var.airgap_url
  friendly_name_prefix        = var.friendly_name_prefix
  tfe_license_secret          = module.secrets.tfe_license
  redis_encryption_at_rest    = false
  redis_encryption_in_transit = false
  redis_require_password      = false
  iam_role_policy_arns        = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iact_subnet_list            = ["0.0.0.0/0"]
  instance_type               = "m5.xlarge"
  key_name                    = aws_key_pair.main.key_name
  kms_key_alias               = var.friendly_name_prefix
  load_balancing_scheme       = "PUBLIC"
  node_count                  = 1
  tfe_subdomain               = var.tfe_subdomain
  asg_tags                    = var.tags
}
