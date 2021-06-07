provider "aws" {}

data "aws_ami" "existing" {
  owners      = var.ami_owners
  most_recent = var.ami_most_recent

  filter {
    name   = var.ami_filter_name
    values = [var.ami_filter_value]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "existing_image_example" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  friendly_name_prefix = var.friendly_name_prefix
  tfe_subdomain        = var.tfe_subdomain
  tfe_license_name     = var.tfe_license_name
  tfe_license_filepath = var.tfe_license_filepath

  ami_id                = data.aws_ami.existing.id
  iact_subnet_list      = var.iact_subnet_list
  load_balancing_scheme = var.load_balancing_scheme

  common_tags = var.common_tags
}
