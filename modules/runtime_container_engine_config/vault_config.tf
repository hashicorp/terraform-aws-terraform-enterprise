# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {

  vault_enable_external = var.vault_address != null ? true : false

  external_vault_config = {
    TFE_VAULT_USE_EXTERNAL = true
    TFE_VAULT_ADDRESS      = var.vault_address
    TFE_VAULT_NAMESPACE    = var.vault_namespace
    TFE_VAULT_PATH         = var.vault_path
    TFE_VAULT_ROLE_ID      = var.vault_role_id
    TFE_VAULT_SECRET_ID    = var.vault_secret_id
    TFE_VAULT_TOKEN_RENEW  = var.vault_token_renew
  }

  vault_cluster_address = {
    TFE_VAULT_CLUSTER_ADDRESS = join("", ["https://", "$HOST_IP", ":8201"])
  }

  vault_configuration = local.vault_enable_external ? local.external_vault_config : local.active_active && !local.vault_enable_external ? local.vault_cluster_address : {}
}
