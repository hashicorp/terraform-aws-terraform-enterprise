# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_string" "password" {
  length  = 16
  special = false
}

locals {
  replicated_base_config = {
    BypassPreflightChecks             = var.bypass_preflight_checks
    DaemonAuthenticationType          = "password"
    DaemonAuthenticationPassword      = random_string.password.result
    ImportSettingsFrom                = "/etc/ptfe-settings.json"
    LicenseFileLocation               = var.tfe_license_file_location
    LicenseBootstrapAirgapPackagePath = var.tfe_license_bootstrap_airgap_package_path
    LicenseBootstrapChannelID         = var.tfe_license_bootstrap_channel_id
    LogLevel                          = var.log_level
    TlsBootstrapHostname              = var.hostname
    TlsBootstrapCert                  = var.tls_bootstrap_cert_pathname
    TlsBootstrapKey                   = var.tls_bootstrap_key_pathname
    TlsBootstrapType                  = var.tls_bootstrap_cert_pathname != null ? "server-path" : "self-signed"
    ReleaseSequence                   = var.tfe_license_bootstrap_airgap_package_path != null ? null : var.release_sequence
  }
}
