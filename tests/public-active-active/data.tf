data "aws_secretsmanager_secret" "tfe_license" {
  name = var.tfe_license_secret_name
}
