provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }

  default_tags {
    tags = local.common_tags
  }
}

provider "vault" {
  address = try (var.vault_address, module.hcp_vault.url)
  token   = try (var.vault_token, module.hcp_vault.token)
}
