output "private_active_active" {
  value = module.private_active_active

  description = "The outputs of the private_active_active module."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}

output "tfe_url" {
  value = module.private_active_active.tfe_url

  description = "The URL to the TFE application."
}

output "health_check_url" {
  value = "${module.private_active_active.tfe_url}/_health_check"

  description = "The URL with path to access the TFE instance health check."
}

output "iact_url" {
  value = "${module.private_active_active.tfe_url}/admin/retrieve-iact"

  description = "The URL with path to access the TFE instance Retrieve IACT."
}

output "initial_admin_user_url" {
  value = "${module.private_active_active.tfe_url}/admin/initial-admin-user"

  description = "The URL with path to access the TFE instance Initial Admin User."
}

output "tfe_instance_id" {
  value = data.aws_instances.main.ids[0]

  description = "The ID of a TFE EC2 instance."
}
