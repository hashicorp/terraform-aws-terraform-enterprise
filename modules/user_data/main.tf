resource "random_string" "password" {
  length  = 16
  special = false
}

resource "random_id" "archivist_token" {
  byte_length = 16
}

resource "random_id" "cookie_hash" {
  byte_length = 16
}

resource "random_id" "enc_password" {
  byte_length = 16
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

locals {
  base_configs = {

    installation_type = {
      value = "production"
    }

    production_type = {
      value = "external"
    }

    hostname = {
      value = var.fqdn
    }
    user_token = {
      value = random_id.user_token.hex
    }

    archivist_token = {
      value = random_id.archivist_token.hex
    }

    cookie_hash = {
      value = random_id.cookie_hash.hex
    }

    root_secret = {
      value = random_id.root_secret.hex
    }

    registry_session_secret_key = {
      value = random_id.registry_session_secret_key.hex
    }

    registry_session_encryption_key = {
      value = random_id.registry_session_encryption_key.hex
    }

    internal_api_token = {
      value = random_id.internal_api_token.hex
    }

    install_id = {
      value = random_id.install_id.hex
    }

    iact_subnet_list = {
      value = join(",", var.iact_subnet_list)
    }

    iact_subnet_time_limit = {
      value = var.iact_subnet_time_limit != null ? tostring(var.iact_subnet_time_limit) : ""
    }
    enc_password = {
      value = random_id.enc_password.hex
    }
  }

  disk_settings = var.enable_disk ? {
    installation_type = {
      value = "production"
    }

    production_type = {
      value = "disk"
    }

    disk_path = {
      value = var.disk_path
    }
  } : {}

  base_external_configs = var.enable_external ? {

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

    placement = {
      value = "placement_s3"
    }

    aws_instance_profile = {
      value = var.aws_access_key_id == null ? "1" : "0"
    }

    aws_access_key_id = {
      value = var.aws_access_key_id
    }

    aws_secret_access_key = {
      value = var.aws_secret_access_key
    }

    s3_bucket = {
      value = var.aws_bucket_data
    }

    s3_region = {
      value = var.aws_region
    }

    s3_sse = {
      value = "aws:kms"
    }

    s3_sse_kms_key_id = {
      value = var.kms_key_arn
    }
  } : {}

  redis_configs = {
    enable_active_active = {
      value = "1"
    }
    redis_host = {
      value = var.redis_host
    }

    redis_pass = {
      value = var.redis_pass
    }

    redis_port = {
      value = var.redis_port
    }

    redis_use_password_auth = {
      value = var.redis_use_password_auth
    }

    redis_use_tls = {
      value = var.redis_use_tls
    }
  }

  external_vault = {

    extern_vault_enable = {
      value = var.extern_vault_enable
    }

    extern_vault_path = {
      value = var.extern_vault_path
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

    extern_vault_token_renew = {
      value = var.extern_vault_token_renew
    }

    extern_vault_namespace = {
      value = var.extern_vault_namespace
    }
  }
}



locals {
  import_settings_from  = "/etc/ptfe-settings.json"
  license_file_location = "/etc/ptfe-license.rli"
  lib_directory         = "/var/lib/ptfe"
  airgap_pathname       = "${local.lib_directory}/ptfe.airgap"
  airgap_config = {
    LicenseBootstrapAirgapPackagePath = local.airgap_pathname
  }
  replicated_base_config = {
    BypassPreflightChecks        = true
    DaemonAuthenticationPassword = random_string.password.result
    DaemonAuthenticationType     = "password"
    ImportSettingsFrom           = local.import_settings_from
    LicenseFileLocation          = local.license_file_location
    TlsBootstrapType             = "self-signed"
    TlsBootstrapHostname         = var.fqdn
  }
}

## Build tfe config json
locals {
  # take all the partials and merge them into the base configs, if false, merging empty map is noop
  is_redis_configs  = var.active_active ? local.redis_configs : {}
  is_airgap         = var.airgap_url == null ? {} : local.airgap_config
  is_external_vault = var.extern_vault_enable == 1 ? local.external_vault : {}
  tfe_configs = jsonencode(merge(
    local.base_configs,
    local.is_redis_configs,
    local.base_external_configs,
    local.disk_settings,
    local.is_external_vault
  ))
}

## build replicated config json
locals {
  repl_configs = jsonencode(merge(local.replicated_base_config, local.is_airgap))
}

locals {
  tfe_user_data = templatefile(
    "${path.module}/templates/tfe_ec2.sh.tpl",
    {
      enable_disk           = var.enable_disk
      disk_path             = var.enable_disk ? var.disk_path : null
      airgap_url            = var.airgap_url
      airgap_pathname       = local.airgap_pathname
      airgap_url            = var.airgap_url
      import_settings_from  = local.import_settings_from
      tfe_license_secret    = var.tfe_license_secret
      license_file_location = local.license_file_location
      replicated            = base64encode(local.repl_configs)
      settings              = base64encode(local.tfe_configs)
      active_active         = var.active_active
      ca_certificate_secret = var.ca_certificate_secret
      proxy_ip              = var.proxy_ip
      no_proxy = join(
        ",",
        concat(
          [
            "127.0.0.1",
            "169.254.169.254",
            ".aws.ce.redhat.com",
          ],
          var.no_proxy
        )
      )
    }
  )
}