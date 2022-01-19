data "aws_secretsmanager_secret" "tfe_license" {
  name = module.secrets.tfe_license
}
