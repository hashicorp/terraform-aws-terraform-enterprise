provider "aws" {
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

module "public_active_active" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  friendly_name_prefix = local.friendly_name_prefix
  tfe_license_name     = "terraform-aws-terraform-enterprise.rli"

  deploy_secretsmanager        = false
  deploy_vpc                   = false
  external_bootstrap_bucket    = var.external_bootstrap_bucket
  iact_subnet_list             = var.iact_subnet_list
  iam_role_policy_arns         = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  instance_type                = "m5.xlarge"
  kms_key_alias                = "${local.friendly_name_prefix}-test-public-active-active"
  load_balancing_scheme        = "PUBLIC"
  network_id                   = var.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_private_subnets      = var.network_private_subnets
  network_public_subnets       = var.network_public_subnets
  node_count                   = 2
  redis_encryption_at_rest     = false
  redis_encryption_in_transit  = false
  redis_require_password       = false
  tfe_license_filepath         = ""
  tfe_subdomain                = "${local.friendly_name_prefix}-test-public-active-active"

  common_tags = local.common_tags
}
