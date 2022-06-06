provider "aws" {
  default_tags {
    tags = var.tags
  }
  assume_role {
    role_arn = var.aws_role_arn
  }
}

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

# MITM Proxy
# ----------
module "test_proxy" {
  source                          = "../../fixtures/test_proxy"
  subnet_id                       = module.active_active.private_subnet_ids[0]
  name                            = local.friendly_name_prefix
  key_name                        = aws_key_pair.main.key_name
  mitmproxy_ca_certificate_secret = data.aws_secretsmanager_secret.ca_certificate.arn
  mitmproxy_ca_private_key_secret = data.aws_secretsmanager_secret.ca_private_key.arn
  vpc_id                          = module.active_active.network_id
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

# Active/Active TFE Architecture
# ------------------------------
module "active_active" {
  source = "../../"

  acm_certificate_arn   = var.acm_certificate_arn
  domain_name           = var.domain_name
  friendly_name_prefix  = local.friendly_name_prefix
  tfe_license_secret_id = module.secrets.tfe_license_secret_id

  ami_id                      = data.aws_ami.rhel.id
  asg_tags                    = var.tags
  distribution                = "rhel"
  ca_certificate_secret_id    = data.aws_secretsmanager_secret.ca_certificate.arn
  iact_subnet_list            = ["0.0.0.0/0"]
  iam_role_policy_arns        = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  instance_type               = "m5.8xlarge"
  kms_key_arn                 = module.kms.key
  load_balancing_scheme       = "PRIVATE_TCP"
  node_count                  = 2
  proxy_ip                    = module.test_proxy.proxy_ip
  proxy_port                  = "3128"
  redis_encryption_at_rest    = true
  redis_encryption_in_transit = true
  redis_use_password_auth     = true
  tfe_subdomain               = var.tfe_subdomain
  tls_bootstrap_cert_pathname = "/var/lib/terraform-enterprise/certificate.pem"
  tls_bootstrap_key_pathname  = "/var/lib/terraform-enterprise/key.pem"
  vm_certificate_secret_id    = var.certificate_pem_secret_id
  vm_key_secret_id            = var.private_key_pem_secret_id
}
