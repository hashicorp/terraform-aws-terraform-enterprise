resource "aws_secretsmanager_secret" "tfe_license" {
  description = "The TFE license."
}

resource "aws_secretsmanager_secret_version" "tfe_license" {
  secret_binary = filebase64(var.license_file)
  secret_id     = aws_secretsmanager_secret.tfe_license.id
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "aws_secretsmanager_secret" "tls_private_key" {
  description = "TLS private key"
}

resource "aws_secretsmanager_secret_version" "tls_private_key" {
  secret_binary = tls_private_key.main.private_key_pem
  secret_id     = aws_secretsmanager_secret.tls_private_key.id
}

resource "aws_secretsmanager_secret" "tls_public_key" {
  description = "TLS public key"
}

resource "aws_secretsmanager_secret_version" "tls_public_key" {
  secret_binary = tls_private_key.main.public_key_openssh
  secret_id     = aws_secretsmanager_secret.tls_public_key.id
}
