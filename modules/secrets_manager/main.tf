resource "aws_secretsmanager_secret" "tfe_install" {
  count = var.deploy_secretsmanager == true ? 1 : 0

  name        = var.secretsmanager_secret_name == null ? "${var.friendly_name_prefix}-tfe-install-secrets" : var.secretsmanager_secret_name
  description = "TFE install secret metadata"

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-install-secrets" },
    var.common_tags
  )
}

resource "aws_secretsmanager_secret_version" "tfe_install_secrets" {
  count = var.secretsmanager_secrets != {} && var.deploy_secretsmanager == true ? 1 : 0

  secret_id     = aws_secretsmanager_secret.tfe_install[0].id
  secret_string = jsonencode(var.secretsmanager_secrets)
}

