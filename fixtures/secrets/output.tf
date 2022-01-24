output "tfe_license" {
  value = var.tfe_license == null ? null : aws_secretsmanager_secret_version.tfe_license[0].secret_id
}

output "ca_certificate_secret" {
  value = var.ca_certificate_secret == null ? null : aws_secretsmanager_secret_version.ca_certificate_secret[0].secret_id
}

output "ca_private_key" {
  value = var.ca_private_key == null ? null : aws_secretsmanager_secret_version.ca_private_key[0].secret_id
}
