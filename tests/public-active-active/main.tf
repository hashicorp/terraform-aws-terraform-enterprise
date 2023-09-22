# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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
  numeric = false
  special = false
}

module "secrets" {
  count  = local.utility_module_test ? 0 : 1
  source = "../../fixtures/secrets"

  tfe_license = {
    name = "${local.friendly_name_prefix}-tfe-license"
    path = var.license_file
  }
}

module "kms" {
  source    = "../../fixtures/kms"
  key_alias = "${local.friendly_name_prefix}-key"
}

module "public_active_active" {
  source = "../../"

  acm_certificate_arn   = var.acm_certificate_arn
  domain_name           = var.domain_name
  friendly_name_prefix  = local.friendly_name_prefix
  distribution          = "ubuntu"
  tfe_license_secret_id = try(module.secrets[0].tfe_license_secret_id, var.tfe_license_secret_id)

  ami_id                        = data.aws_ami.ubuntu.id
  consolidated_services_enabled = var.consolidated_services_enabled
  iam_role_policy_arns          = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iact_subnet_list              = var.iact_subnet_list
  instance_type                 = "m5.xlarge"
  key_name                      = var.key_name
  kms_key_arn                   = module.kms.key
  load_balancing_scheme         = local.load_balancing_scheme
  node_count                    = 2
  redis_encryption_at_rest      = false
  redis_encryption_in_transit   = false
  redis_use_password_auth       = false
  tfe_subdomain                 = local.test_name
  tls_bootstrap_cert_pathname   = "/etc/ssl/private/terraform-enterprise/cert.pem"
  tls_bootstrap_key_pathname    = "/etc/ssl/private/terraform-enterprise/key.pem"
  vm_certificate_secret_id      = data.aws_secretsmanager_secret.vm_certificate.id
  vm_key_secret_id              = data.aws_secretsmanager_secret.vm_key.id

  asg_tags = local.common_tags

  # FDO Specific Values
  is_replicated_deployment  = var.is_replicated_deployment
  hc_license                = var.hc_license
  license_reporting_opt_out = true
  registry_password         = var.registry_password
  registry_username         = var.registry_username
  tfe_image                 = "quay.io/hashicorp/terraform-enterprise:${var.tfe_image_tag}"
}
