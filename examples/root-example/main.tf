provider "aws" {
  region = "us-west-2"
}

module "tfe-cluster" {
  source  = "hashicorp/terraform-enterprise/aws"
  version = "0.1.0"

  vpc_id       = "vpc-123456789abcd1234"
  domain       = "example.com"
  license_file = "company.rli"
}

output "tfe-beta" {
  value = {
    application_endpoint         = module.tfe-cluster.application_endpoint
    application_health_check     = module.tfe-cluster.application_health_check
    iam_role                     = module.tfe-cluster.iam_role
    install_id                   = module.tfe-cluster.install_id
    installer_dashboard_password = module.tfe-cluster.installer_dashboard_password
    installer_dashboard_url      = module.tfe-cluster.installer_dashboard_url
    primary_public_ip            = module.tfe-cluster.primary_public_ip
    ssh_private_key              = module.tfe-cluster.ssh_private_key
  }
}
