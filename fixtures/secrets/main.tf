resource "aws_secretsmanager_secret" "tfe_license" {
  description = "The TFE license."
}

resource "aws_secretsmanager_secret_version" "tfe_license" {
  secret_binary = filebase64("${path.module}/${var.tfe_license.path}")
  secret_id     = aws_secretsmanager_secret.tfe_license.id
}

