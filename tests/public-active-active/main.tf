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

module "public_active_active" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  friendly_name_prefix = local.friendly_name_prefix
  tfe_license_secret   = data.aws_secretsmanager_secret.tfe_license.arn

  iam_role_policy_arns        = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iact_subnet_list            = var.iact_subnet_list
  instance_type               = "m5.xlarge"
  key_name                    = var.key_name
  kms_key_arn                 = module.kms.key
  load_balancing_scheme       = "PUBLIC"
  node_count                  = 2
  redis_encryption_at_rest    = false
  redis_encryption_in_transit = false
  redis_require_password      = false
  tfe_subdomain               = local.test_name

  asg_tags = local.common_tags
}
