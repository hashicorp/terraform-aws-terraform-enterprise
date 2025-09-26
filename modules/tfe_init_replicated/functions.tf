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

  install_monitoring_agents = templatefile("${path.module}/templates/install_monitoring_agents.func", {
    cloud             = var.cloud
    distribution      = var.distribution
    enable_monitoring = var.enable_monitoring != null ? var.enable_monitoring : false
  })

  retry = templatefile("${path.module}/templates/retry.func", {
    cloud = var.cloud
  })
}
