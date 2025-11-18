# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  kms_key_arn                     = data.aws_kms_key.main.arn
  enable_airgap                   = var.airgap_url == null && var.tfe_license_bootstrap_airgap_package_path != null
  enable_external                 = var.operational_mode == "external" || var.operational_mode == "active-active"
  enable_disk                     = var.operational_mode == "disk"
  enable_database_module          = local.enable_external && var.enable_aurora == false && var.db_use_mtls == false && var.enable_edb == false
  enable_explorer_database_module = local.enable_external && var.db_use_mtls == false && var.explorer_db_name != null
  enable_object_storage_module    = local.enable_external
  enable_redis_module             = var.operational_mode == "active-active"
  redis_mtls_enabled              = var.enable_redis_mtls
  fdo_operational_mode            = var.operational_mode
  ami_id                          = local.default_ami_id ? data.aws_ami.ubuntu.id : var.ami_id
  default_ami_id                  = var.ami_id == null
  fqdn                            = "${var.tfe_subdomain}.${var.domain_name}"
  iam_principal                   = { arn = try(var.object_storage_iam_user.arn, module.service_accounts.iam_role.arn) }
  network_id                      = var.deploy_vpc ? module.networking[0].network_id : var.network_id
  network_private_subnets         = var.deploy_vpc ? module.networking[0].network_private_subnets : var.network_private_subnets
  network_public_subnets          = var.deploy_vpc ? module.networking[0].network_public_subnets : var.network_public_subnets
  network_private_subnet_cidrs    = var.deploy_vpc ? module.networking[0].network_private_subnet_cidrs : var.network_private_subnet_cidrs

  explorer_database = try(module.explorer_database[0], local.default_database)

  default_database = {
    name                  = null
    password              = null
    endpoint              = null
    username              = null
    parameters            = null
    iam_user_setup_status = null
  }

  aurora_database = try(module.aurora_database[0], local.default_database)
  mtls_database   = try(module.database_mtls[0], local.default_database)
  enterprise_db   = try(module.edb[0], local.default_database)
  standard_db     = try(module.database[0], local.default_database)

  selected_database = (
    var.enable_aurora && var.db_use_mtls ? error("Both enable_aurora and db_use_mtls cannot be true.") :
    var.enable_aurora ? local.aurora_database :
    var.db_use_mtls ? local.mtls_database :
    var.enable_edb ? local.enterprise_db :
    local.standard_db
  )

  # PostgreSQL IAM authentication flag
  database_passwordless_aws_use_iam = var.database_passwordless_aws_use_iam || (var.postgres_enable_iam_auth && !var.postgres_use_password_auth)

  # Database IAM database name - simple and predictable
  database_iam_name = local.database_passwordless_aws_use_iam && !var.enable_aurora && !var.db_use_mtls && !var.enable_edb ? "${var.db_iam_username}_db" : local.database.name

  # Database IAM instance profile - use the existing service account profile
  database_iam_instance_profile = module.service_accounts.iam_instance_profile.name

  database = local.selected_database

  object_storage = try(
    module.object_storage[0],
    {
      s3_bucket = {
        id = null
      }
    }
  )
  redis_default = {
    hostname                          = null
    password                          = null
    username                          = null
    redis_port                        = null
    use_password_auth                 = null
    use_tls                           = null
    sentinel_enabled                  = var.enable_redis_sentinel
    sentinel_hosts                    = []
    sentinel_leader                   = null
    sentinel_username                 = null
    sentinel_password                 = null
    aws_elasticache_subnet_group_name = null
    aws_security_group_redis          = null
  }
  redis = var.enable_redis_sentinel || var.enable_sentinel_mtls ? module.redis_sentinel[0] : var.enable_redis_mtls ? module.redis_mtls[0] : try(module.redis[0], local.redis_default)

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
