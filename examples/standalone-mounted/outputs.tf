output "ptfe_endpoint" {
  value       = module.standalone.tfe_url
  description = "The URL to the TFE application."
}

output "replicated_console_url" {
  value       = "${module.standalone.tfe_url}:8800"
  description = "Terraform Enterprise Console URL"
}

output "ptfe_health_check" {
  value       = "${module.standalone.tfe_url}/_health_check"
  description = "The URL with path to access the TFE instance health check."
}

output "replicated_console_password" {
  value       = module.standalone.replicated_dashboard_password
  description = "The password for the TFE console"
  sensitive   = true
}
