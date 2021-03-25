locals {
  complete_prefix = "${var.prefix}-${random_string.friendly_name.result}"
  http_proxy_port = 3128
}

resource "random_pet" "subdomain" {
  length    = 2
  separator = "-"
  prefix    = var.prefix
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
    values = ["RHEL-7.4_HVM-*-x86_64-*-Hourly2-GP2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "bank_deployment" {
  source = "../../"

  tfe_license_filepath = var.license_path
  tfe_license_name     = "replicated_license.rli"

  tfe_subdomain = (var.tfe_subdomain == null) ? random_pet.subdomain.id : var.tfe_subdomain
  domain_name   = var.domain_name

  friendly_name_prefix = "${var.prefix}-${random_string.friendly_name.result}"

  node_count = 2

  deploy_secretsmanager = false

  acm_certificate_arn = var.acm_certificate_arn

  bastion_keypair = var.existing_aws_keypair

  proxy_cert_bundle_filepath = local_file.ca.filename
  proxy_cert_bundle_name     = "mitmproxy"
  proxy_ip                   = "${aws_instance.proxy.private_ip}:${local.http_proxy_port}"

  ami_id = data.aws_ami.rhel.id

  load_balancing_scheme = "PRIVATE_TCP"

  redis_require_password      = true
  redis_encryption_in_transit = true
  redis_encryption_at_rest    = true

  common_tags = var.common_tags
}
