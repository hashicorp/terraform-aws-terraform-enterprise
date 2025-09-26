# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  get_base64_secrets = templatefile("${path.module}/templates/get_base64_secrets.func", {
    cloud = var.cloud
  })

  install_packages = templatefile("${path.module}/templates/install_packages.func", {
    cloud        = var.cloud
    distribution = var.distribution
  })

  install_jq = templatefile("${path.module}/templates/install_jq.func", {
    distribution = var.distribution
  })

  install_monitoring_agents = templatefile("${path.module}/templates/install_monitoring_agents.func", {
    cloud             = var.cloud
    distribution      = var.distribution
    enable_monitoring = var.enable_monitoring != null ? var.enable_monitoring : false
  })

  quadlet_unit = templatefile("${path.module}/templates/terraform-enterprise.kube.tpl", {})

  retry = templatefile("${path.module}/templates/retry.func", {
    cloud = var.cloud
  })

  azurerm_database_init = templatefile("${path.module}/templates/azurerm_database_init.func.tpl", {
    distribution            = var.distribution
    msi_auth_enabled        = var.database_passwordless_azure_use_msi
    database_host           = var.database_host
    database_name           = var.database_name
    admin_database_username = var.admin_database_username
    admin_database_password = var.admin_database_password
  })
  get_unmounted_disk = file("${path.module}/templates/get_unmounted_disk.func")
}
