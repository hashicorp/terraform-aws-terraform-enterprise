output "tfe_license" {
  value = aws_secretsmanager_secret_version.tfe_license[0].secret_id
}

output "ca_certificate_secret" {
  value = aws_secretsmanager_secret_version.ca_certificate_secret[0].secret_id
}

output "ca_private_key" {
  value = aws_secretsmanager_secret_version.ca_private_key[0].secret_id
}

output "ssl_certificate" {
  value = aws_secretsmanager_secret_version.ssl_certificate[0].secret_id
}

output "ssl_private_key" {
  value = aws_secretsmanager_secret_version.ssl_private_key[0].secret_id
}

