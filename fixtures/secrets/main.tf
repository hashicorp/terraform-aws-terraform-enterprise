resource "aws_secretsmanager_secret" "tfe_license" {
  count       = var.tfe_license == null ? 0 : 1
  name        = var.tfe_license.name
  description = "The TFE license."
}

resource "aws_secretsmanager_secret_version" "tfe_license" {
  count         = var.tfe_license == null ? 0 : 1
  secret_binary = filebase64(var.tfe_license.path)
  secret_id     = aws_secretsmanager_secret.tfe_license[count.index].id
}

resource "aws_secretsmanager_secret" "ca_certificate_secret" {
  count       = var.ca_certificate_secret == null ? 0 : 1
  name        = "ca_certificate_secret"
  description = "The CA certificate"
}

resource "aws_secretsmanager_secret_version" "ca_certificate_secret" {
  count         = var.ca_certificate_secret == null ? 0 : 1
  secret_binary = base64encode(var.ca_certificate_secret)
  secret_id     = aws_secretsmanager_secret.ca_certificate_secret[count.index].id
}

resource "aws_secretsmanager_secret" "ca_private_key" {
  name        = var.ca_private_key.id
  count       = var.ca_private_key == null ? 0 : 1
  description = "CA Certificate private key"
}

resource "aws_secretsmanager_secret_version" "ca_private_key" {
  count         = var.ca_private_key == null ? 0 : 1
  secret_binary = base64encode(var.ca_private_key.data)
  secret_id     = aws_secretsmanager_secret.ca_private_key[count.index].id
}