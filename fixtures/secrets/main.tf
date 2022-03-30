resource "aws_secretsmanager_secret" "tfe_license" {
  count       = var.tfe_license == null ? 0 : 1
  name        = var.tfe_license.name
  description = "The TFE license"
}

resource "aws_secretsmanager_secret_version" "tfe_license" {
  count         = var.tfe_license == null ? 0 : 1
  secret_binary = filebase64(var.tfe_license.path)
  secret_id     = aws_secretsmanager_secret.tfe_license[count.index].id
}

resource "aws_secretsmanager_secret" "ca_certificate_secret" {
  count       = var.ca_certificate_secret == null ? 0 : 1
  name        = var.ca_certificate_secret.name
  description = "The CA certificate"
}

resource "aws_secretsmanager_secret_version" "ca_certificate_secret" {
  count         = var.ca_certificate_secret == null ? 0 : 1
  secret_binary = base64encode(var.ca_certificate_secret.data)
  secret_id     = aws_secretsmanager_secret.ca_certificate_secret[count.index].id
}

resource "aws_secretsmanager_secret" "ca_private_key_secret" {
  count       = var.ca_private_key_secret == null ? 0 : 1
  name        = var.ca_private_key_secret.name
  description = "CA Certificate private key"
}

resource "aws_secretsmanager_secret_version" "ca_private_key_secret" {
  count         = var.ca_private_key_secret == null ? 0 : 1
  secret_binary = base64encode(var.ca_private_key_secret.data)
  secret_id     = aws_secretsmanager_secret.ca_private_key_secret[count.index].id
}

resource "aws_secretsmanager_secret" "certificate_pem_secret" {
  count       = var.certificate_pem_secret == null ? 0 : 1
  name        = var.certificate_pem_secret.name
  description = "The PEM-encoded TLS certificate"
}

resource "aws_secretsmanager_secret_version" "certificate_pem_secret" {
  count         = var.certificate_pem_secret == null ? 0 : 1
  secret_binary = base64encode(var.certificate_pem_secret.data)
  secret_id     = aws_secretsmanager_secret.certificate_pem_secret[count.index].id
}

resource "aws_secretsmanager_secret" "private_key_pem_secret" {
  count       = var.private_key_pem_secret == null ? 0 : 1
  name        = var.private_key_pem_secret.name
  description = "The PEM-encoded TLS private key"
}

resource "aws_secretsmanager_secret_version" "private_key_pem_secret" {
  count         = var.private_key_pem_secret == null ? 0 : 1
  secret_binary = base64encode(var.private_key_pem_secret.data)
  secret_id     = aws_secretsmanager_secret.private_key_pem_secret[count.index].id
}