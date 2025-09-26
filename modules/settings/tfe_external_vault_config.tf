# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  extern_vault_configs = {
    extern_vault_enable = {
      value = var.extern_vault_enable != null ? var.extern_vault_enable ? "1" : "0" : null
    }

    extern_vault_addr = {
      value = var.extern_vault_addr
    }

    extern_vault_role_id = {
      value = var.extern_vault_role_id
    }

    extern_vault_secret_id = {
      value = var.extern_vault_secret_id
    }

    extern_vault_path = {
      value = var.extern_vault_path
    }

    extern_vault_token_renew = {
      value = var.extern_vault_token_renew != null ? tostring(var.extern_vault_token_renew) : null
    }

    extern_vault_namespace = {
      value = var.extern_vault_namespace
    }

    extern_vault_propagate = {
      value = var.extern_vault_propagate != null ? var.extern_vault_propagate ? "1" : "0" : null
    }
  }

  external_vault_configs = var.extern_vault_enable != null ? var.extern_vault_enable ? local.extern_vault_configs : {} : {}
}