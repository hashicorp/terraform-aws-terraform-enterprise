output "existing_image" {
  value       = module.existing_image
  description = "The output of all the existing_image module."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}

output "login_url" {
  value       = module.existing_image.tfe_url
  description = "The URL to the TFE application."
}

output "health_check_url" {
  value       = "${module.existing_image.tfe_url}/_health_check"
  description = "The URL with path to access the TFE instance health check."
}

output "iact_url" {
  value       = "${module.existing_image.tfe_url}/admin/retrieve-iact"
  description = "The URL with path to access the TFE instance Retrieve IACT."
}

output "initial_admin_user_url" {
  value       = "${module.existing_image.tfe_url}/admin/initial-admin-user"
  description = "The URL with path to access the TFE instance Initial Admin User."
}