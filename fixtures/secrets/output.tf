output "tfe_license_secret_id" {
  value = var.tfe_license == null ? null : aws_secretsmanager_secret_version.tfe_license[0].secret_id
}

output "ca_certificate_secret_id" {
  value = var.ca_certificate_secret == null ? null : aws_secretsmanager_secret_version.ca_certificate_secret[0].secret_id
}

output "ca_private_key_secret_id" {
  value = var.ca_private_key_secret == null ? null : aws_secretsmanager_secret_version.ca_private_key_secret[0].secret_id
}

output "certificate_pem_secret_id" {
  value = var.certificate_pem_secret == null ? null : aws_secretsmanager_secret_version.certificate_pem_secret[0].secret_id
}

output "private_key_pem_secret_id" {
  value = var.private_key_pem_secret == null ? null : aws_secretsmanager_secret_version.private_key_pem_secret[0].secret_id
}