data "aws_region" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_kms_key" "main" {
  key_id = var.kms_key_arn
}

# -----------------------------------------------------------------------------
# AWS Service Accounts 
# -----------------------------------------------------------------------------
module "service_accounts" {
  source = "./modules/service_accounts"

  ca_certificate_secret_id = var.ca_certificate_secret_id
  friendly_name_prefix     = var.friendly_name_prefix
  iam_role_policy_arns     = var.iam_role_policy_arns
  enable_airgap            = local.enable_airgap
  tfe_license_secret_id    = var.tfe_license_secret_id
  kms_key_arn              = local.kms_key_arn
  vm_certificate_secret_id = var.vm_certificate_secret_id
  vm_key_secret_id         = var.vm_key_secret_id
}

# -----------------------------------------------------------------------------
# AWS S3 Bucket Object Storage
# -----------------------------------------------------------------------------
module "object_storage" {

  count  = local.enable_object_storage_module ? 1 : 0
  source = "./modules/object_storage"

  friendly_name_prefix = var.friendly_name_prefix
  iam_principal        = local.iam_principal
  kms_key_arn          = local.kms_key_arn
}

# -----------------------------------------------------------------------------
# AWS Virtual Private Cloud Networking
# -----------------------------------------------------------------------------
module "networking" {
  count = var.deploy_vpc ? 1 : 0

  source = "./modules/networking"

  friendly_name_prefix         = var.friendly_name_prefix
  network_cidr                 = var.network_cidr
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_public_subnet_cidrs  = var.network_public_subnet_cidrs
}

# -----------------------------------------------------------------------------
# AWS Redis - Elasticache Replication Group
# -----------------------------------------------------------------------------
module "redis" {
  source = "./modules/redis"

  count = local.enable_redis_module ? 1 : 0

  active_active                = local.active_active
  friendly_name_prefix         = var.friendly_name_prefix
  network_id                   = local.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_subnets_private      = local.network_private_subnets
  tfe_instance_sg              = module.vm.tfe_instance_sg

  cache_size           = var.redis_cache_size
  engine_version       = var.redis_engine_version
  parameter_group_name = var.redis_parameter_group_name

  kms_key_arn                 = local.kms_key_arn
  redis_encryption_in_transit = var.redis_encryption_in_transit
  redis_encryption_at_rest    = var.redis_encryption_at_rest
  redis_use_password_auth     = var.redis_use_password_auth
  redis_port                  = var.redis_encryption_in_transit ? "6380" : "6379"
}

# -----------------------------------------------------------------------------
# AWS PostreSQL Database
# -----------------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  count = local.enable_database_module ? 1 : 0

  db_size                      = var.db_size
  db_backup_retention          = var.db_backup_retention
  db_backup_window             = var.db_backup_window
  engine_version               = var.postgres_engine_version
  friendly_name_prefix         = var.friendly_name_prefix
  network_id                   = local.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_subnets_private      = local.network_private_subnets
  tfe_instance_sg              = module.vm.tfe_instance_sg
  kms_key_arn                  = local.kms_key_arn
}

# -----------------------------------------------------------------------------
# TFE and Replicated settings to pass to the tfe_init module
# -----------------------------------------------------------------------------
module "settings" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/settings?ref=main"

  # TFE Base Configuration
  custom_image_tag       = var.custom_image_tag
  production_type        = var.operational_mode
  disk_path              = local.enable_disk ? var.disk_path : null
  iact_subnet_list       = var.iact_subnet_list
  iact_subnet_time_limit = var.iact_subnet_time_limit
  trusted_proxies        = var.trusted_proxies
  release_sequence       = var.release_sequence
  pg_extra_params        = var.pg_extra_params
  tbw_image              = var.tbw_image

  extra_no_proxy = concat([
    "127.0.0.1",
    "169.254.169.254",
    ".aws.ce.redhat.com",
    "secretsmanager.${data.aws_region.current.name}.amazonaws.com",
    local.fqdn,
    var.network_cidr
  ], var.no_proxy)

  # Replicated Base Configuration
  hostname                                  = local.fqdn
  enable_active_active                      = local.active_active
  tfe_license_bootstrap_airgap_package_path = var.tfe_license_bootstrap_airgap_package_path
  tfe_license_file_location                 = var.tfe_license_file_location
  tls_bootstrap_cert_pathname               = var.tls_bootstrap_cert_pathname
  tls_bootstrap_key_pathname                = var.tls_bootstrap_key_pathname
  bypass_preflight_checks                   = var.bypass_preflight_checks

  # Database
  pg_dbname   = local.database.name
  pg_netloc   = local.database.endpoint
  pg_user     = local.database.username
  pg_password = local.database.password

  # Redis
  redis_host              = local.redis.hostname
  redis_pass              = local.redis.password
  redis_use_tls           = local.redis.use_tls
  redis_use_password_auth = local.redis.use_password_auth

  # AWS Object Store
  aws_access_key_id     = var.aws_access_key_id
  s3_bucket             = local.object_storage.s3_bucket.id
  s3_region             = data.aws_region.current.name
  aws_secret_access_key = var.aws_secret_access_key
  s3_sse                = "aws:kms"
  s3_sse_kms_key_id     = local.kms_key_arn

  # External Vault
  extern_vault_enable      = var.extern_vault_enable
  extern_vault_addr        = var.extern_vault_addr
  extern_vault_role_id     = var.extern_vault_role_id
  extern_vault_secret_id   = var.extern_vault_secret_id
  extern_vault_path        = var.extern_vault_path
  extern_vault_token_renew = var.extern_vault_token_renew
  extern_vault_namespace   = var.extern_vault_namespace
}

# -----------------------------------------------------------------------------
# AWS user data / cloud init used to install and configure TFE on instance(s)
# -----------------------------------------------------------------------------
module "tfe_init" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/tfe_init?ref=main"

  # TFE & Replicated Configuration data
  cloud                    = "aws"
  disk_path                = local.enable_disk ? var.disk_path : null
  disk_device_name         = local.enable_disk ? var.ebs_renamed_device_name : null
  distribution             = var.distribution
  tfe_configuration        = module.settings.tfe_configuration
  replicated_configuration = module.settings.replicated_configuration
  airgap_url               = var.airgap_url

  # Secrets
  ca_certificate_secret_id = var.ca_certificate_secret_id == null ? null : var.ca_certificate_secret_id
  certificate_secret_id    = var.vm_certificate_secret_id == null ? null : var.vm_certificate_secret_id
  key_secret_id            = var.vm_key_secret_id == null ? null : var.vm_key_secret_id
  tfe_license_secret_id    = var.tfe_license_secret_id

  # Proxy information
  proxy_ip   = var.proxy_ip
  proxy_port = var.proxy_port
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
}

module "vm" {
  source = "./modules/vm"

  active_active                       = local.active_active
  aws_iam_instance_profile            = module.service_accounts.iam_instance_profile.name
  ami_id                              = local.ami_id
  aws_lb                              = var.load_balancing_scheme == "PRIVATE_TCP" ? null : module.load_balancer[0].aws_lb_security_group
  aws_lb_target_group_tfe_tg_443_arn  = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].aws_lb_target_group_tfe_tg_443_arn : module.load_balancer[0].aws_lb_target_group_tfe_tg_443_arn
  aws_lb_target_group_tfe_tg_8800_arn = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].aws_lb_target_group_tfe_tg_8800_arn : module.load_balancer[0].aws_lb_target_group_tfe_tg_8800_arn
  asg_tags                            = var.asg_tags
  default_ami_id                      = local.default_ami_id
  enable_disk                         = local.enable_disk
  ebs_device_name                     = var.ebs_device_name
  ebs_volume_size                     = var.ebs_volume_size
  ebs_volume_type                     = var.ebs_volume_type
  ebs_iops                            = var.ebs_iops
  ebs_delete_on_termination           = var.ebs_delete_on_termination
  friendly_name_prefix                = var.friendly_name_prefix
  key_name                            = var.key_name
  instance_type                       = var.instance_type
  network_id                          = local.network_id
  network_subnets_private             = local.network_private_subnets
  network_private_subnet_cidrs        = local.network_private_subnet_cidrs
  node_count                          = var.node_count
  user_data_base64                    = module.tfe_init.tfe_userdata_base64_encoded
}
