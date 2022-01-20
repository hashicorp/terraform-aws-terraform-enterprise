output "tfe_license" {
  value = aws_secretsmanager_secret_version.tfe_license[0].secret_id
}

output "tfe_license" {
  value = aws_secretsmanager_secret_version.ca_certificate[0].secret_id
}

output "tfe_license" {
  value = aws_secretsmanager_secret_version.ca_private_key[0].secret_id
}

output "tfe_license" {
  value = aws_secretsmanager_secret_version.ssl_certificate[0].secret_id
}

output "tfe_license" {
  value = aws_secretsmanager_secret_version.ssl_private_key[0].secret_id
}

