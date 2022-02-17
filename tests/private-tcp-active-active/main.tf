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

module "private_tcp_active_active" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  friendly_name_prefix = local.friendly_name_prefix
  tfe_license_secret   = data.aws_secretsmanager_secret.tfe_license.arn

  ami_id                      = data.aws_ami.rhel.id
  ca_certificate_secret       = data.aws_secretsmanager_secret.ca_certificate.arn
  iact_subnet_list            = ["0.0.0.0/0"]
  iam_role_policy_arns        = [local.ssm_policy_arn, "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  instance_type               = "m5.8xlarge"
  kms_key_arn                 = module.kms.key
  load_balancing_scheme       = "PRIVATE_TCP"
  node_count                  = 2
  proxy_ip                    = "${aws_instance.proxy.private_ip}:${local.http_proxy_port}"
  redis_encryption_at_rest    = true
  redis_encryption_in_transit = true
  redis_require_password      = true
  tfe_subdomain               = local.test_name

  asg_tags = local.common_tags
}
