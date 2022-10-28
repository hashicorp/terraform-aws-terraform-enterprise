output "active_active" {
  value = module.active_active_airgap

  description = "The outputs of the active_active module."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}

output "login_url" {
  value = module.active_active_airgap.tfe_url

  description = "The URL to the TFE application."
}

output "health_check_url" {
  value = "${module.active_active_airgap.tfe_url}/_health_check"

  description = "The URL with path to access the TFE instance health check."
}

output "iact_url" {
  value = "${module.active_active_airgap.tfe_url}/admin/retrieve-iact"

  description = "The URL with path to access the TFE instance Retrieve IACT."
}

output "initial_admin_user_url" {
  value = "${module.active_active_airgap.tfe_url}/admin/initial-admin-user"

  description = "The URL with path to access the TFE instance Initial Admin User."
}

output "tfe_autoscaling_group_name" {
  value = module.active_active_airgap.tfe_autoscaling_group.name

  description = "The name of the autoscaling group which hosts the TFE EC2 instance(s)."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}