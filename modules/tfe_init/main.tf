# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {

  tls_bootstrap_path          = "/etc/tfe/ssl"
  tls_bootstrap_cert_pathname = "${local.tls_bootstrap_path}/cert.pem"
  tls_bootstrap_key_pathname  = "${local.tls_bootstrap_path}/key.pem"
  tls_bootstrap_ca_pathname   = "${local.tls_bootstrap_path}/bundle.pem"

  postgres_bootstrap_path          = "/etc/tfe/ssl/postgres"
  postgres_bootstrap_cert_pathname = "${local.postgres_bootstrap_path}/cert.crt"
  postgres_bootstrap_key_pathname  = "${local.postgres_bootstrap_path}/key.key"
  postgres_bootstrap_ca_pathname   = "${local.postgres_bootstrap_path}/ca.crt"

  redis_bootstrap_path          = "/etc/tfe/ssl/redis"
  redis_bootstrap_cert_pathname = "${local.redis_bootstrap_path}/cert.pem"
  redis_bootstrap_key_pathname  = "${local.redis_bootstrap_path}/key.pem"
  redis_bootstrap_ca_pathname   = "${local.redis_bootstrap_path}/cacert.pem"

  user_data_template = {
    aws = {
      ubuntu = {
        docker = "${path.module}/templates/aws.ubuntu.docker.tfe.sh.tpl",
        podman = null
      },
      rhel = {
        docker = "${path.module}/templates/aws.rhel.docker.tfe.sh.tpl",
        podman = "${path.module}/templates/aws.rhel.podman.tfe.sh.tpl",
      }
    },
    azurerm = {
      ubuntu = {
        docker = "${path.module}/templates/azurerm.ubuntu.docker.tfe.sh.tpl",
        podman = null
      },
      rhel = {
        docker = "${path.module}/templates/azurerm.rhel.docker.tfe.sh.tpl",
        podman = "${path.module}/templates/azurerm.rhel.podman.tfe.sh.tpl",
      }
    }
    google = {
      ubuntu = {
        docker = "${path.module}/templates/google.ubuntu.docker.tfe.sh.tpl",
        podman = null
      },
      rhel = {
        docker = "${path.module}/templates/google.rhel.docker.tfe.sh.tpl",
        podman = "${path.module}/templates/google.rhel.podman.tfe.sh.tpl",
      }
    }
  }
  tfe_user_data = templatefile(
    local.user_data_template[var.cloud][var.distribution][var.container_runtime_engine],
    {
      get_base64_secrets        = local.get_base64_secrets
      install_packages          = local.install_packages
      install_jq                = local.install_jq
      install_monitoring_agents = local.install_monitoring_agents
      retry                     = local.retry
      quadlet_unit              = local.quadlet_unit
      azurerm_database_init     = local.azurerm_database_init
      get_unmounted_disk        = local.get_unmounted_disk

      active_active               = var.operational_mode == "active-active"
      cloud                       = var.cloud
      custom_image_tag            = try(var.custom_image_tag, null)
      disk_path                   = var.disk_path
      disk_device_name            = var.disk_device_name
      distribution                = var.distribution
      docker_config               = filebase64("${path.module}/files/daemon.json")
      docker_version              = var.distribution == "rhel" ? var.docker_version_rhel : null
      enable_monitoring           = var.enable_monitoring != null ? var.enable_monitoring : false
      tls_bootstrap_cert_pathname = local.tls_bootstrap_cert_pathname
      tls_bootstrap_key_pathname  = local.tls_bootstrap_key_pathname
      tls_bootstrap_ca_pathname   = local.tls_bootstrap_ca_pathname
      docker_compose              = var.docker_compose_yaml
      podman_kube_config          = var.podman_kube_yaml

      ca_certificate_secret_id = var.ca_certificate_secret_id
      certificate_secret_id    = var.certificate_secret_id
      key_secret_id            = var.key_secret_id

      postgres_bootstrap_cert_pathname = local.postgres_bootstrap_cert_pathname
      postgres_bootstrap_key_pathname  = local.postgres_bootstrap_key_pathname
      postgres_bootstrap_ca_pathname   = local.postgres_bootstrap_ca_pathname

      enable_redis_mtls              = var.enable_redis_mtls
      enable_sentinel_mtls           = var.enable_sentinel_mtls
      redis_ca_certificate_secret_id = var.redis_ca_certificate_secret_id
      redis_certificate_secret_id    = var.redis_client_certificate_secret_id
      redis_client_key_secret_id     = var.redis_client_key_secret_id

      enable_postgres_mtls              = var.enable_postgres_mtls
      postgres_ca_certificate_secret_id = var.postgres_ca_certificate_secret_id
      postgres_certificate_secret_id    = var.postgres_client_certificate_secret_id
      postgres_client_key_secret_id     = var.postgres_client_key_secret_id

      redis_bootstrap_cert_pathname = local.redis_bootstrap_cert_pathname
      redis_bootstrap_key_pathname  = local.redis_bootstrap_key_pathname
      redis_bootstrap_ca_pathname   = local.redis_bootstrap_ca_pathname

      database_azure_msi_auth_enabled = var.database_passwordless_azure_use_msi

      proxy_ip   = var.proxy_ip
      proxy_port = var.proxy_port
      no_proxy   = var.extra_no_proxy != null ? join(",", var.extra_no_proxy) : null

      registry            = var.registry
      registry_password   = var.registry_password
      registry_username   = var.registry_username
      registry_credential = base64encode("${var.registry_username}:${var.registry_password}")

      tfe_image = var.tfe_image
  })
}
