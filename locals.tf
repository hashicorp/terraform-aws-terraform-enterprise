locals {
  active_active                = var.node_count >= 2
  kms_key_arn                  = data.aws_kms_key.main.arn
  enable_airgap                = var.airgap_url == null && var.tfe_license_bootstrap_airgap_package_path != null
  enable_external              = var.operational_mode == "external" || local.active_active
  enable_disk                  = var.operational_mode == "disk"
  enable_database_module       = local.enable_external
  enable_object_storage_module = local.enable_external
  enable_redis_module          = local.active_active
  ami_id                       = local.default_ami_id ? data.aws_ami.ubuntu.id : var.ami_id
  default_ami_id               = var.ami_id == null
  fqdn                         = "${var.tfe_subdomain}.${var.domain_name}"
  iam_principal                = { arn = try(var.object_storage_iam_user.arn, module.service_accounts.iam_role.arn) }
  network_id                   = var.deploy_vpc ? module.networking[0].network_id : var.network_id
  network_private_subnets      = var.deploy_vpc ? module.networking[0].network_private_subnets : var.network_private_subnets
  network_public_subnets       = var.deploy_vpc ? module.networking[0].network_public_subnets : var.network_public_subnets
  network_private_subnet_cidrs = var.deploy_vpc ? module.networking[0].network_private_subnet_cidrs : var.network_private_subnet_cidrs

  database = try(
    module.database[0],
    {
      name     = null
      password = null
      endpoint = null
      username = null
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

}
