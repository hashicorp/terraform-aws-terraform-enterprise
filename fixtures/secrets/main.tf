resource "aws_secretsmanager_secret" "tfe_license" {
  count = var.tfe_license == null ? 0 : 1
  description = "The TFE license."
}

resource "aws_secretsmanager_secret_version" "tfe_license" {
  count = var.tfe_license == null ? 0 : 1
  secret_binary = filebase64(var.tfe_license.path)
  secret_id     = aws_secretsmanager_secret.tfe_license[count.index].id
}

resource "aws_secretsmanager_secret" "ca_certificate" {
  count = var.ca_certificate == null ? 0 : 1
  description = "The CA certificate"
}

resource "aws_secretsmanager_secret_version" "ca_certificate" {
  count = var.ca_certificate == null ? 0 : 1
  secret_binary = filebase64(var.ca_certificate.path)
  secret_id     = aws_secretsmanager_secret.ca_certificate[count.index].id
}


resource "aws_secretsmanager_secret" "ca_private_key" {
  count = var.ca_private_key == null ? 0 : 1
  description = "CA Certificate private key"
}

resource "aws_secretsmanager_secret_version" "ca_private_key" {
  count = var.ca_private_key == null ? 0 : 1
  secret_binary = filebase64(var.ca_private_key.path)
  secret_id     = aws_secretsmanager_secret.ca_private_key[count.index].id
}

resource "aws_secretsmanager_secret" "ssl_certificate" {
  count = var.ssl_certificate == null ? 0 : 1
  description = "SSl certificate"
}

resource "aws_secretsmanager_secret_version" "ssl_certificate" {
  count = var.ssl_certificate == null ? 0 : 1
  secret_binary = filebase64(var.ssl_certificate.path)
  secret_id     = aws_secretsmanager_secret.ssl_certificate[count.index].id
}

resource "aws_secretsmanager_secret" "ssl_private_key" {
  count = var.ssl_private_key == null ? 0 : 1
  description = "SSL certificate private key"
}

resource "aws_secretsmanager_secret_version" "ssl_private_key" {
  count = var.ssl_private_key == null ? 0 : 1
  secret_binary = filebase64(var.ssl_private_key.path)
  secret_id     = aws_secretsmanager_secret.ssl_private_key[count.index].id
}


