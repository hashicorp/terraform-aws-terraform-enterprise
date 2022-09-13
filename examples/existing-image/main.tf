resource "random_string" "friendly_name" {
  length  = 4
  upper   = false # Some AWS resources do not accept uppercase characters.
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

# Key Management Service
# ----------------------
module "kms" {
  source    = "../../fixtures/kms"
  key_alias = "${local.friendly_name_prefix}-key"
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

# TFE installation into an existing vm image
# ------------------------------------------
module "existing_image" {
  source = "../../"

  acm_certificate_arn   = var.acm_certificate_arn
  domain_name           = var.domain_name
  friendly_name_prefix  = local.friendly_name_prefix
  tfe_subdomain         = var.tfe_subdomain
  tfe_license_secret_id = module.secrets.tfe_license_secret_id

  ami_id                = local.ami_id
  distribution          = "ubuntu"
  iact_subnet_list      = var.iact_subnet_list
  key_name              = aws_key_pair.main.key_name
  kms_key_arn           = module.kms.key
  load_balancing_scheme = "PUBLIC"

  asg_tags = var.tags
}
