output "tfe_license" {
  value = aws_secretsmanager_secret_version.tfe_license.secret_id
}
