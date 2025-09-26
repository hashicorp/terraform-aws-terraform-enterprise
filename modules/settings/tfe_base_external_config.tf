# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  pg_configs = {
    enable_active_active = {
      value = var.production_type == "active-active" ? "1" : "0"
    }

    pg_dbname = {
      value = var.pg_dbname
    }

    pg_netloc = {
      value = var.pg_netloc
    }

    pg_password = {
      value = var.pg_password
    }

    pg_user = {
      value = var.pg_user
    }

    log_forwarding_config = {
      value = var.log_forwarding_config
    }

    log_forwarding_enabled = {
      value = var.log_forwarding_enabled != null ? var.log_forwarding_enabled ? "1" : "0" : null
    }

  }

  pg_optional_configs = {
    pg_extra_params = {
      value = var.pg_extra_params
    }
  }

  base_external_configs = local.pg_optional_configs != null && (var.production_type == "active-active" || var.production_type == "external") ? (merge(local.pg_configs, local.pg_optional_configs)) : local.pg_configs
}
