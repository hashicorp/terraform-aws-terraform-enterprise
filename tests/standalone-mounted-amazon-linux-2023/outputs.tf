# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "login_url" {
  value       = module.standalone.tfe_url
  description = "The URL to the TFE application."
}

output "tfe_console_url" {
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
