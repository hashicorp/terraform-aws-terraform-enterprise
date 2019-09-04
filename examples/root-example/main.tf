provider "aws" {
  region = "us-west-2"
}

module "tfe-beta" {
  source  = "hashicorp/terraform-enterprise/aws"
  version = "0.0.1-beta"

  vpc_id       = "vpc-123456789abcd1234"
  domain       = "example.com"
  license_file = "company.rli"
}

output "tfe-beta" {
  value = {
    application_endpoint         = "${module.tfe-beta.application_endpoint}"
    application_health_check     = "${module.tfe-beta.application_health_check}"
    iam_role                     = "${module.tfe-beta.iam_role}"
    install_id                   = "${module.tfe-beta.install_id}"
    installer_dashboard_password = "${module.tfe-beta.installer_dashboard_password}"
    installer_dashboard_url      = "${module.tfe-beta.installer_dashboard_url}"
    primary_public_ip            = "${module.tfe-beta.primary_public_ip}"
    ssh_private_key              = "${module.tfe-beta.ssh_private_key}"
  }
}
