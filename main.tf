data "aws_region" "current" {}

resource "aws_kms_key" "tfe_key" {
  deletion_window_in_days = var.kms_key_deletion_window
  description             = "AWS KMS Customer-managed key to encrypt TFE and other resources"
  enable_key_rotation     = true
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"

  # Prefix removed until https://github.com/hashicorp/terraform-provider-aws/issues/19583 is resolved
  tags = {
    # Name = "${var.friendly_name_prefix}-tfe-kms-key"
    Name = "tfe-kms-key"
  }
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.tfe_key.key_id
}

locals {
  active_active = var.node_count >= 2
  fqdn          = var.custom_fqdn != null ? var.custom_fqdn : "${var.tfe_subdomain}.${var.domain_name}"
}

module "object_storage" {
  source = "./modules/object_storage"

  friendly_name_prefix = var.friendly_name_prefix
  kms_key_arn          = aws_kms_key.tfe_key.arn
  logging_bucket       = var.logging_bucket
  logging_prefix       = var.logging_prefix
}

module "service_accounts" {
  source = "./modules/service_accounts"

  aws_bucket_data_arn   = module.object_storage.s3_bucket_data_arn
  ca_certificate_secret = var.ca_certificate_secret
  friendly_name_prefix  = var.friendly_name_prefix
  kms_key_arn           = aws_kms_key.tfe_key.arn
  iam_role_policy_arns  = var.iam_role_policy_arns
  tfe_license_secret    = var.tfe_license_secret
}

module "networking" {
  count = var.deploy_vpc ? 1 : 0

  source = "./modules/networking"

  friendly_name_prefix         = var.friendly_name_prefix
  network_cidr                 = var.network_cidr
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_public_subnet_cidrs  = var.network_public_subnet_cidrs
}

locals {
  network_id                   = var.deploy_vpc ? module.networking[0].network_id : var.network_id
  network_private_subnets      = var.deploy_vpc ? module.networking[0].network_private_subnets : var.network_private_subnets
  network_public_subnets       = var.deploy_vpc ? module.networking[0].network_public_subnets : var.network_public_subnets
  network_private_subnet_cidrs = var.deploy_vpc ? module.networking[0].network_private_subnet_cidrs : var.network_private_subnet_cidrs
}

module "redis" {
  source = "./modules/redis"

  active_active                = local.active_active
  friendly_name_prefix         = var.friendly_name_prefix
  network_id                   = local.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_subnets_private      = local.network_private_subnets
  tfe_instance_sg              = module.vm.tfe_instance_sg

  cache_size           = var.redis_cache_size
  engine_version       = var.redis_engine_version
  parameter_group_name = var.redis_parameter_group_name

  kms_key_arn                 = aws_kms_key.tfe_key.arn
  redis_encryption_in_transit = var.redis_encryption_in_transit
  redis_encryption_at_rest    = var.redis_encryption_at_rest
  redis_require_password      = var.redis_require_password
}

module "database" {
  source = "./modules/database"

  db_size                      = var.db_size
  db_backup_retention          = var.db_backup_retention
  db_backup_window             = var.db_backup_window
  engine_version               = var.postgres_engine_version
  friendly_name_prefix         = var.friendly_name_prefix
  monitoring_interval          = var.db_monitoring_interval
  network_id                   = local.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_subnets_private      = local.network_private_subnets
  tfe_instance_sg              = module.vm.tfe_instance_sg
  enabled_cloudwatch_logs      = var.db_enabled_cloudwatch_logs
  tags                         = var.db_tags
}

module "user_data" {
  source = "./modules/user_data"

  active_active           = local.active_active
  aws_bucket_data         = module.object_storage.s3_bucket_data
  aws_region              = data.aws_region.current.name
  fqdn                    = local.fqdn
  iact_subnet_list        = var.iact_subnet_list
  iact_subnet_time_limit  = var.iact_subnet_time_limit
  kms_key_arn             = aws_kms_key.tfe_key.arn
  pg_dbname               = module.database.db_name
  pg_password             = module.database.db_password
  pg_netloc               = module.database.db_endpoint
  pg_user                 = module.database.db_username
  ca_certificate_secret   = var.ca_certificate_secret
  proxy_ip                = var.proxy_ip
  no_proxy                = var.no_proxy
  redis_host              = module.redis.redis_endpoint
  redis_pass              = module.redis.redis_password
  redis_port              = module.redis.redis_port
  redis_use_password_auth = module.redis.redis_use_password_auth
  redis_use_tls           = module.redis.redis_transit_encryption_enabled
  tfe_license_secret      = var.tfe_license_secret
}

module "load_balancer" {
  count  = var.load_balancing_scheme != "PRIVATE_TCP" ? 1 : 0
  source = "./modules/application_load_balancer"

  active_active                  = local.active_active
  admin_dashboard_ingress_ranges = var.admin_dashboard_ingress_ranges
  certificate_arn                = var.acm_certificate_arn
  domain_name                    = var.domain_name
  friendly_name_prefix           = var.friendly_name_prefix
  fqdn                           = local.fqdn
  load_balancing_scheme          = var.load_balancing_scheme
  network_id                     = local.network_id
  network_public_subnets         = local.network_public_subnets
  network_private_subnets        = local.network_private_subnets
  ssl_policy                     = var.ssl_policy
  logging_bucket                 = var.logging_bucket
  logging_prefix                 = var.logging_prefix
}

module "private_tcp_load_balancer" {
  count  = var.load_balancing_scheme == "PRIVATE_TCP" ? 1 : 0
  source = "./modules/network_load_balancer"

  active_active           = local.active_active
  certificate_arn         = var.acm_certificate_arn
  domain_name             = var.domain_name
  friendly_name_prefix    = var.friendly_name_prefix
  fqdn                    = local.fqdn
  network_id              = local.network_id
  network_private_subnets = local.network_private_subnets
  ssl_policy              = var.ssl_policy
  logging_bucket          = var.logging_bucket
  logging_prefix          = var.logging_prefix
}

module "vm" {
  source = "./modules/vm"

  active_active                       = local.active_active
  aws_iam_instance_profile            = module.service_accounts.aws_iam_instance_profile
  ami_id                              = var.ami_id
  ami_kms_key_arn                     = var.ami_kms_key_arn
  aws_lb                              = var.load_balancing_scheme == "PRIVATE_TCP" ? null : module.load_balancer[0].aws_lb_security_group
  aws_lb_target_group_tfe_tg_443_arn  = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].aws_lb_target_group_tfe_tg_443_arn : module.load_balancer[0].aws_lb_target_group_tfe_tg_443_arn
  aws_lb_target_group_tfe_tg_8800_arn = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].aws_lb_target_group_tfe_tg_8800_arn : module.load_balancer[0].aws_lb_target_group_tfe_tg_8800_arn
  asg_tags                            = var.asg_tags
  friendly_name_prefix                = var.friendly_name_prefix
  key_name                            = var.key_name
  instance_type                       = var.instance_type
  network_id                          = local.network_id
  network_subnets_private             = local.network_private_subnets
  network_private_subnet_cidrs        = local.network_private_subnet_cidrs
  node_count                          = var.node_count
  user_data_base64                    = module.user_data.tfe_user_data_base64
  health_check_grace_period           = var.health_check_grace_period
}
