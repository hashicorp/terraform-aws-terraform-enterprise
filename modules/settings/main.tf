# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  replicated_configuration = { for k, v in local.replicated_base_config : k => v if v != tostring(null) }

  tfe_merged_configuration = merge(
    local.base_configs,
    local.base_external_configs,
    local.external_aws_configs,
    local.external_azure_configs,
    local.external_google_configs,
    local.redis_configuration,
    local.external_vault_configs
  )

  tfe_configuration_remove_null = { for k, v in flatten([local.tfe_merged_configuration]).0 : k => v if v.value != tostring(null) }
  tfe_configuration             = { for k, v in local.tfe_configuration_remove_null : k => v if v.value != "" }
}

resource "random_id" "archivist_token" {
  byte_length = 16
}

resource "random_id" "cookie_hash" {
  byte_length = 16
}

resource "random_password" "enc_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "random_id" "install_id" {
  byte_length = 16
}

resource "random_id" "internal_api_token" {
  byte_length = 16
}

resource "random_id" "root_secret" {
  byte_length = 16
}

resource "random_id" "registry_session_secret_key" {
  byte_length = 16
}

resource "random_id" "registry_session_encryption_key" {
  byte_length = 16
}

resource "random_id" "user_token" {
  byte_length = 16
}
