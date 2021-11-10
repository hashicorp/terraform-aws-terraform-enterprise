output "replicated_console_password" {
  value       = module.tfe.replicated_dashboard_password
  description = "The password for the TFE console"
}

output "replicated_console_url" {
  value       = module.tfe.replicated_console_url
  description = "Terraform Enterprise Console URL"
}

output "ptfe_endpoint" {
  value       = module.tfe.tfe_url
  description = "Terraform Enterprise Application URL"
}

output "ptfe_health_check" {
  value       = module.tfe.health_check_url
  description = "Terraform Enterprise Health Check URL"
}

output "ssh_config_file" {
  value = local_file.ssh_config.filename

  description = "The pathname of the SSH configuration file that grants access to the compute instance."
}

output "ssh_private_key" {
  value = local_file.private_key_pem.filename

  description = "The pathname of the private SSH key."
}
