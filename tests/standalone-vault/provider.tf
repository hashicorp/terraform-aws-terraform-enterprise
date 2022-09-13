provider "vault" {
  address = hcp_vault_cluster.test.vault_public_endpoint_url
  token   = hcp_vault_cluster_admin_token.test.token
}

provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }
}
