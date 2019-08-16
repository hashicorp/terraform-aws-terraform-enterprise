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

output "ssh_private_key" {
  value = "${module.tfe-ha.ssh_private_key}"
}

output "replicated_console_password" {
  value = "${module.tfe-ha.replicated_console_password}"
}

output "replicated_console_url" {
  value = "${module.tfe-ha.replicated_console_url}"
}

output "ptfe_endpoint" {
  value = "${module.ptfe-ha.ptfe_endpoint}"
}

output "ptfe_health_check" {
  value = "${module.ptfe-ha.ptfe_health_check"
}

output "primary_public_ip" {
  value = "${module.ptfe-ha.primary_public_ip}"
}

output "lb_endpoint" {
  value = "${module.tfe-ha.lb_endpoint}"
}

output "iam_role" {
  value = "${module.tfe-ha.iam_role}"
}

output "install_id" {
  value = "${module.tfe-ha.install_id}"
}
