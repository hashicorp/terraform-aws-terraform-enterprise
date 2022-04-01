provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }

  default_tags {
    tags = local.common_tags
  }
}

resource "random_string" "friendly_name" {
  length  = 4
  upper   = false # Some AWS resources do not accept uppercase characters.
  number  = false
  special = false
}

module "kms" {
  source    = "../../fixtures/kms"
  key_alias = "${local.friendly_name_prefix}-key"
}

module "test_proxy" {
  source    = "../../fixtures/test_proxy"
  key_name  = var.key_name
  subnet_id = module.private_active_active.private_subnet_ids[0]
  name      = local.friendly_name_prefix
  vpc_id    = module.private_active_active.network_id
}

module "private_active_active" {
  source = "../../"

  acm_certificate_arn   = var.acm_certificate_arn
  domain_name           = var.domain_name
  friendly_name_prefix  = local.friendly_name_prefix
  tfe_license_secret_id = data.aws_secretsmanager_secret.tfe_license.arn

  ami_id                      = data.aws_ami.rhel.id
  distribution                = "rhel"
  iact_subnet_list            = ["0.0.0.0/0"]
  iam_role_policy_arns        = [local.ssm_policy_arn, "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  instance_type               = "m5.4xlarge"
  key_name                    = var.key_name
  kms_key_arn                 = module.kms.key
  load_balancing_scheme       = local.load_balancing_scheme
  node_count                  = 2
  proxy_ip                    = module.test_proxy.proxy_ip
  proxy_port                  = local.http_proxy_port
  redis_encryption_at_rest    = false
  redis_encryption_in_transit = true
  redis_use_password_auth     = true
  tfe_subdomain               = local.test_name

  asg_tags = local.common_tags
}
