# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "replicated_console_password" {
  value       = module.tfe.replicated_dashboard_password
  description = "The password for the TFE console"
  sensitive   = true
}

output "replicated_console_url" {
  value       = module.tfe.replicated_console_url
  description = "Terraform Enterprise Console URL"
}

output "ptfe_endpoint" {
  value       = module.tfe.tfe_url
  description = "Terraform Enterprise Application URL"
}

output "tfe_url" {
  value       = module.tfe.tfe_url
  description = "The URL to the TFE application."
}

# Change this to health_check_url for consistency. This requires changing it in ptfe-replicated tests.
output "ptfe_health_check" {
  value       = module.tfe.health_check_url
  description = "Terraform Enterprise Health Check URL"
}

output "health_check_url" {
  value       = module.tfe.health_check_url
  description = "The URL with path to access the TFE instance health check."
}
output "ssh_config_file" {
  value       = local.utility_module_test ? "use AWS SSH key define by var.key_name" : local_file.ssh_config[0].filename
  description = "The pathname of the SSH configuration file that grants access to the compute instance."
}

output "ssh_private_key" {
  value       = local.utility_module_test ? "use AWS SSH key define by var.key_name" : local_file.private_key_pem[0].filename
  description = "The pathname of the private SSH key."
}

output "proxy_instance_id" {
  value       = module.test_proxy.proxy_instance_id
  description = "The ID of the proxy EC2 instance."
}