provider "aws" {
  region = "us-west-2"
}

module "tfe-ha" {
  source = "github.com/hashicorp/terraform-aws-tfe-ha"

  version = "0.1.0"
  vpc_id          = "vpc-123456789abcd1234"
  domain          = "example.com"
  license_file    = "company.rli"
  secondary_count = "3"
  primary_count   = "3"
  distribution    = "ubuntu"
}

output "tfe-ha" {
  value = {
    ssh_private_key = "${module.tfe-ha.ssh_private_key}"
    replicated_console_password = "${module.tfe-ha.replicated_console_password}"
    replicated_console_url = "${module.tfe-ha.replicated_console_url}"
    ptfe_endpoint = "${module.ptfe-ha.ptfe_endpoint}"
    ptfe_health_check = "${module.ptfe-ha.ptfe_health_check}"
    primary_public_ip = "${module.ptfe-ha.primary_public_ip}"
    lb_endpoint = "${module.tfe-ha.lb_endpoint}"
    iam_role = "${module.tfe-ha.iam_role}"
    install_id = "${module.tfe-ha.install_id}"
  }
}