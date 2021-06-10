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

data "aws_ami" "rhel" {
  owners = ["309956199498"] # RedHat

  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7.9_HVM-*-x86_64-*-Hourly2-GP2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  http_proxy_port = 3128
}

module "private_active_active" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  friendly_name_prefix = local.friendly_name_prefix
  tfe_license_name     = "terraform-aws-terraform-enterprise.rli"

  ami_id                       = data.aws_ami.rhel.id
  deploy_secretsmanager        = false
  deploy_vpc                   = false
  external_bootstrap_bucket    = var.external_bootstrap_bucket
  iact_subnet_list             = ["0.0.0.0/0"]
  iam_role_policy_arns         = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  instance_type                = "m5.4xlarge"
  key_name                     = var.key_name
  kms_key_alias                = "${local.friendly_name_prefix}-test-private-active-active"
  load_balancing_scheme        = "PRIVATE"
  network_id                   = var.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_private_subnets      = var.network_private_subnets
  network_public_subnets       = var.network_public_subnets
  node_count                   = 2
  proxy_ip                     = "${aws_instance.proxy.private_ip}:${local.http_proxy_port}"
  redis_encryption_at_rest     = false
  redis_encryption_in_transit  = true
  redis_require_password       = true
  tfe_license_filepath         = ""
  tfe_subdomain                = "${local.friendly_name_prefix}-test-private-active-active"

  common_tags = local.common_tags
}

data "aws_instances" "main" {
  instance_tags = local.common_tags

  depends_on = [
    module.private_active_active
  ]
}
