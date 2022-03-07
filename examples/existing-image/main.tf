locals {
  ami_search = var.ami_id == null ? true : false
  ami_id     = local.ami_search ? data.aws_ami.existing[0].id : var.ami_id
}

data "aws_ami" "existing" {
  count = local.ami_search ? 1 : 0

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

# Store TFE License as secret
# ---------------------------

module "secrets" {
  source = "../../fixtures/secrets"
  tfe_license = {
    name = "${var.friendly_name_prefix}-license"
    path = var.license_file
  }
}

module "existing_image_example" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  friendly_name_prefix = var.friendly_name_prefix
  tfe_subdomain        = var.tfe_subdomain
  tfe_license_secret   = module.secrets.tfe_license

  ami_id                = local.ami_id
  iact_subnet_list      = var.iact_subnet_list
  load_balancing_scheme = var.load_balancing_scheme
}
