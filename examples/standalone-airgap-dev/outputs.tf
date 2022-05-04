output "login_url" {
  value       = module.standalone_airgap_dev.tfe_url
  description = "The URL to the TFE application."
}

output "tfe_console_url" {
  value       = "${module.standalone_airgap_dev.tfe_url}:8800"
  description = "Terraform Enterprise Console URL"
}

output "ptfe_health_check" {
  value       = "${module.standalone_airgap_dev.tfe_url}/_health_check"
  description = "The URL with path to access the TFE instance health check."
}

output "replicated_console_password" {
  value       = module.standalone_airgap_dev.replicated_dashboard_password
  description = "The password for the TFE console"
  sensitive   = true
}
