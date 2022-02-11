locals {
  active_active                = var.node_count >= 2
  enable_external              = var.operational_mode == "external" || local.active_active
  enable_database_module       = local.enable_external
  enable_object_storage_module = local.enable_external
  enable_redis_module          = local.active_active
  enable_disk                  = var.operational_mode == "disk" && !local.active_active
  disk_path                    = var.operational_mode == "disk" ? var.disk_path : null
  ami_id                       = local.default_ami_id ? data.aws_ami.ubuntu.id : var.ami_id
  default_ami_id               = var.ami_id == ""
  fqdn                         = "${var.tfe_subdomain}.${var.domain_name}"
  iam_principal                = { arn = try(var.object_storage_iam_user.arn, module.service_accounts.iam_role.arn) }
  network_id                   = var.deploy_vpc ? module.networking[0].network_id : var.network_id
  network_private_subnets      = var.deploy_vpc ? module.networking[0].network_private_subnets : var.network_private_subnets
  network_public_subnets       = var.deploy_vpc ? module.networking[0].network_public_subnets : var.network_public_subnets
  network_private_subnet_cidrs = var.deploy_vpc ? module.networking[0].network_private_subnet_cidrs : var.network_private_subnet_cidrs

  database = try(
    module.database[0],
    {
      db_name     = null
      db_password = null
      db_endpoint = null
      db_username = null
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
      redis_endpoint                   = null
      redis_password                   = null
      redis_port                       = null
      redis_use_password_auth          = null
      redis_transit_encryption_enabled = null
    }
  )

}
