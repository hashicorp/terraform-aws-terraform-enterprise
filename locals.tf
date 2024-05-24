# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  active_active                = var.node_count >= 2 || var.operational_mode == "active-active"
  kms_key_arn                  = data.aws_kms_key.main.arn
  enable_airgap                = var.airgap_url == null && var.tfe_license_bootstrap_airgap_package_path != null
  enable_external              = var.operational_mode == "external" || local.active_active
  enable_disk                  = var.operational_mode == "disk"
  enable_database_module       = local.enable_external && var.enable_aurora == false
  enable_object_storage_module = local.enable_external
  enable_redis_module          = local.active_active
  fdo_operational_mode         = var.operational_mode
  ami_id                       = local.default_ami_id ? data.aws_ami.ubuntu.id : var.ami_id
  default_ami_id               = var.ami_id == null
  fqdn                         = "${var.tfe_subdomain}.${var.domain_name}"
  iam_principal                = { arn = try(var.object_storage_iam_user.arn, module.service_accounts.iam_role.arn) }
  network_id                   = var.deploy_vpc ? module.networking[0].network_id : var.network_id
  network_private_subnets      = var.deploy_vpc ? module.networking[0].network_private_subnets : var.network_private_subnets
  network_public_subnets       = var.deploy_vpc ? module.networking[0].network_public_subnets : var.network_public_subnets
  network_private_subnet_cidrs = var.deploy_vpc ? module.networking[0].network_private_subnet_cidrs : var.network_private_subnet_cidrs

  database = var.enable_aurora ? try(
    module.aurora_database[0],
    {
      name       = null
      password   = null
      endpoint   = null
      username   = null
      parameters = null
    }
    ) : try(
    module.database[0],
    {
      name       = null
      password   = null
      endpoint   = null
      username   = null
      parameters = null
    }
  )

  object_storage = try(
    module.object_storage[0],
    {
      s3_bucket = {
        id = null
      }
    }
  )

  redis = try(
    module.redis[0],
    {
      hostname          = null
      password          = null
      redis_port        = null
      use_password_auth = null
      use_tls           = null
    }
  )

  no_proxy = concat([
    "127.0.0.1",
    "169.254.169.254",
    "secretsmanager.${data.aws_region.current.name}.amazonaws.com",
    ".docker.com",
    ".docker.io",
    "localhost",
    "s3.amazonaws.com",
    ".s3.amazonaws.com",
    "s3.${data.aws_region.current.name}.amazonaws.com",
    local.fqdn,
    var.network_cidr],
    local.replicated_no_proxy,
    local.rhel_no_proxy,
    var.no_proxy
  )

  replicated_no_proxy = var.is_replicated_deployment ? [
    ".replicated.com",
  ] : []

  rhel_no_proxy = var.distribution == "rhel" ? [
    ".aws.ce.redhat.com",
    ".centos.org",
    ".subscription.rhn.redhat.com",
    ".cdn.redhat.com",
  ] : []

  trusted_proxies = concat(
    var.trusted_proxies,
    var.network_private_subnet_cidrs
  )
}
