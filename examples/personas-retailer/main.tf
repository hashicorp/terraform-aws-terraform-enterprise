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
    values = ["RHEL-7.9_HVM-*-x86_64-*-Hourly2-GP2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  complete_prefix = "${var.prefix}-${random_string.friendly_name.result}"
  http_proxy_port = 3128
}

module "retailer_deployment" {
  source = "../../"

  tfe_license_filepath = var.license_path
  tfe_license_name     = "replicated_license.rli"

  tfe_subdomain = (var.tfe_subdomain == null) ? random_pet.subdomain.id : var.tfe_subdomain
  domain_name   = var.domain_name

  friendly_name_prefix = local.complete_prefix

  node_count = 2

  deploy_secretsmanager = false

  acm_certificate_arn = var.acm_certificate_arn

  deploy_bastion  = true
  bastion_keypair = var.existing_aws_keypair

  proxy_ip = "${aws_instance.proxy.private_ip}:${local.http_proxy_port}"

  ami_id = data.aws_ami.rhel.id

  load_balancing_scheme = "PRIVATE"

  redis_encryption_in_transit = true
  redis_require_password      = true
  redis_encryption_at_rest    = false
}
