locals {
  secret_arns = [for secret in [var.ca_certificate_secret_id, var.tfe_license_secret_id] : secret if secret != null]
}
