# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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

  ca_certificate_secret_id           = var.ca_certificate_secret_id
  friendly_name_prefix               = var.friendly_name_prefix
  existing_iam_instance_role_name    = var.existing_iam_instance_role_name
  existing_iam_instance_profile_name = var.existing_iam_instance_profile_name
  iam_role_policy_arns               = var.iam_role_policy_arns
  enable_airgap                      = local.enable_airgap
  tfe_license_secret_id              = var.tfe_license_secret_id
  kms_key_arn                        = local.kms_key_arn
  vm_certificate_secret_id           = var.vm_certificate_secret_id
  vm_key_secret_id                   = var.vm_key_secret_id
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
  count  = var.deploy_vpc ? 1 : 0
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
  count  = local.enable_redis_module ? 1 : 0

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
  count  = local.enable_database_module ? 1 : 0

  db_size                      = var.db_size
  db_backup_retention          = var.db_backup_retention
  db_backup_window             = var.db_backup_window
  db_name                      = var.db_name
  db_parameters                = var.db_parameters
  db_username                  = var.db_username
  engine_version               = var.postgres_engine_version
  friendly_name_prefix         = var.friendly_name_prefix
  network_id                   = local.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_subnets_private      = local.network_private_subnets
  tfe_instance_sg              = module.vm.tfe_instance_sg
  kms_key_arn                  = local.kms_key_arn
}

# -----------------------------------------------------------------------------
# AWS Aurora PostreSQL Database Cluster
# -----------------------------------------------------------------------------
module "aurora_database" {
  source = "./modules/aurora_database_cluster"
  count  = var.enable_aurora ? 1 : 0

  engine_version                        = var.aurora_postgres_engine_version
  db_size                               = var.aurora_db_size
  aurora_db_username                    = var.aurora_db_username
  aurora_db_password                    = var.aurora_db_password
  aurora_cluster_instance_replica_count = var.aurora_cluster_instance_replica_count
  aurora_cluster_instance_enable_single = var.aurora_cluster_instance_enable_single

  db_backup_retention = var.aurora_db_backup_retention
  db_backup_window    = var.db_backup_window
  db_name             = var.db_name
  db_parameters       = var.db_parameters

  friendly_name_prefix         = var.friendly_name_prefix
  network_id                   = local.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_subnets_private      = local.network_private_subnets
  tfe_instance_sg              = module.vm.tfe_instance_sg
  kms_key_id                   = local.kms_key_arn
}

# ------------------------------------------------------------------------------------
# Docker Compose File Config for TFE on instance(s) using Flexible Deployment Options
# ------------------------------------------------------------------------------------
module "runtime_container_engine_config" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/runtime_container_engine_config?ref=main"
  count  = var.is_replicated_deployment ? 0 : 1

  tfe_license = var.hc_license

  disk_path                   = var.operational_mode == "disk" ? var.disk_path : null
  hostname                    = local.fqdn
  http_port                   = var.http_port
  https_port                  = var.https_port
  http_proxy                  = var.proxy_ip != null ? "${var.proxy_ip}:${var.proxy_port}" : null
  https_proxy                 = var.proxy_ip != null ? "${var.proxy_ip}:${var.proxy_port}" : null
  no_proxy                    = var.proxy_ip != null ? local.no_proxy : null
  license_reporting_opt_out   = var.license_reporting_opt_out
  operational_mode            = local.fdo_operational_mode
  metrics_endpoint_enabled    = var.metrics_endpoint_enabled
  metrics_endpoint_port_http  = var.metrics_endpoint_port_http
  metrics_endpoint_port_https = var.metrics_endpoint_port_https

  cert_file          = "/etc/ssl/private/terraform-enterprise/cert.pem"
  key_file           = "/etc/ssl/private/terraform-enterprise/key.pem"
  tfe_image          = var.tfe_image
  tls_ca_bundle_file = var.ca_certificate_secret_id != null ? "/etc/ssl/private/terraform-enterprise/bundle.pem" : null
  tls_ciphers        = var.tls_ciphers
  tls_version        = var.tls_version

  capacity_concurrency = var.capacity_concurrency
  capacity_cpu         = var.capacity_cpu
  capacity_memory      = var.capacity_memory
  iact_subnets         = join(",", var.iact_subnet_list)
  iact_time_limit      = var.iact_subnet_time_limit
  run_pipeline_image   = var.run_pipeline_image

  database_name       = local.database.name
  database_user       = local.database.username
  database_password   = local.database.password
  database_host       = local.database.endpoint
  database_parameters = local.database.parameters

  storage_type                         = "s3"
  s3_access_key_id                     = var.aws_access_key_id
  s3_secret_access_key                 = var.aws_secret_access_key
  s3_bucket                            = local.object_storage.s3_bucket.id
  s3_region                            = data.aws_region.current.name
  s3_endpoint                          = var.s3_endpoint
  s3_server_side_encryption            = "aws:kms"
  s3_server_side_encryption_kms_key_id = local.kms_key_arn
  s3_use_instance_profile              = var.aws_access_key_id == null ? "1" : "0"

  redis_host     = local.redis.hostname
  redis_user     = ""
  redis_password = local.redis.password
  redis_use_tls  = local.redis.use_tls
  redis_use_auth = local.redis.use_password_auth

  trusted_proxies = local.trusted_proxies

  vault_address     = var.extern_vault_addr
  vault_namespace   = var.extern_vault_namespace
  vault_path        = var.extern_vault_path
  vault_role_id     = var.extern_vault_role_id
  vault_secret_id   = var.extern_vault_secret_id
  vault_token_renew = var.extern_vault_token_renew
}

# --------------------------------------------------------------------------------------------------
# AWS cloud init used to install and configure TFE on instance(s) using Flexible Deployment Options
# --------------------------------------------------------------------------------------------------
module "tfe_init_fdo" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/tfe_init?ref=main"
  count  = var.is_replicated_deployment ? 0 : 1

  cloud             = "aws"
  operational_mode  = local.fdo_operational_mode
  custom_image_tag  = var.custom_image_tag
  enable_monitoring = var.enable_monitoring

  disk_path        = local.enable_disk ? var.disk_path : null
  disk_device_name = local.enable_disk ? var.ebs_renamed_device_name : null
  distribution     = var.distribution

  ca_certificate_secret_id = var.ca_certificate_secret_id == null ? null : var.ca_certificate_secret_id
  certificate_secret_id    = var.vm_certificate_secret_id == null ? null : var.vm_certificate_secret_id
  key_secret_id            = var.vm_key_secret_id == null ? null : var.vm_key_secret_id

  proxy_ip       = var.proxy_ip != null ? var.proxy_ip : null
  proxy_port     = var.proxy_ip != null ? var.proxy_port : null
  extra_no_proxy = var.proxy_ip != null ? local.no_proxy : null

  registry          = var.registry
  registry_password = var.registry == "images.releases.hashicorp.com" ? var.hc_license : var.registry_password
  registry_username = var.registry_username

  container_runtime_engine = var.container_runtime_engine
  tfe_image                = var.tfe_image
  podman_kube_yaml         = module.runtime_container_engine_config[0].podman_kube_yaml
  docker_compose_yaml      = module.runtime_container_engine_config[0].docker_compose_yaml
}

# --------------------------------------------------------------------------------------------
# TFE and Replicated settings to pass to the tfe_init_replicated module for replicated deployment
# --------------------------------------------------------------------------------------------
module "settings" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/settings?ref=main"
  count  = var.is_replicated_deployment ? 1 : 0

  # TFE Base Configuration
  custom_image_tag            = var.custom_image_tag
  custom_agent_image_tag      = var.custom_agent_image_tag
  hairpin_addressing          = var.hairpin_addressing
  production_type             = var.operational_mode
  disk_path                   = local.enable_disk ? var.disk_path : null
  iact_subnet_list            = var.iact_subnet_list
  iact_subnet_time_limit      = var.iact_subnet_time_limit
  metrics_endpoint_enabled    = var.metrics_endpoint_enabled
  metrics_endpoint_port_http  = var.metrics_endpoint_port_http
  metrics_endpoint_port_https = var.metrics_endpoint_port_https
  trusted_proxies             = local.trusted_proxies
  release_sequence            = var.release_sequence
  pg_extra_params             = var.pg_extra_params

  extra_no_proxy = local.no_proxy

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
module "tfe_init_replicated" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/tfe_init_replicated?ref=main"
  count  = var.is_replicated_deployment ? 1 : 0

  # TFE & Replicated Configuration data
  cloud                    = "aws"
  disk_path                = local.enable_disk ? var.disk_path : null
  disk_device_name         = local.enable_disk ? var.ebs_renamed_device_name : null
  distribution             = var.distribution
  tfe_configuration        = module.settings[0].tfe_configuration
  replicated_configuration = module.settings[0].replicated_configuration
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

  active_active                          = local.active_active
  aws_iam_instance_profile               = module.service_accounts.iam_instance_profile.name
  ami_id                                 = local.ami_id
  aws_lb                                 = var.load_balancing_scheme == "PRIVATE_TCP" ? null : module.load_balancer[0].aws_lb_security_group
  aws_lb_target_group_tfe_tg_443_arn     = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].aws_lb_target_group_tfe_tg_443_arn : module.load_balancer[0].aws_lb_target_group_tfe_tg_443_arn
  aws_lb_target_group_tfe_tg_8800_arn    = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].aws_lb_target_group_tfe_tg_8800_arn : module.load_balancer[0].aws_lb_target_group_tfe_tg_8800_arn
  asg_tags                               = var.asg_tags
  ec2_launch_template_tag_specifications = var.ec2_launch_template_tag_specifications
  default_ami_id                         = local.default_ami_id
  enable_disk                            = local.enable_disk
  enable_ssh                             = var.enable_ssh
  ebs_device_name                        = var.ebs_device_name
  ebs_volume_size                        = var.ebs_volume_size
  ebs_volume_type                        = var.ebs_volume_type
  ebs_iops                               = var.ebs_iops
  ebs_delete_on_termination              = var.ebs_delete_on_termination
  ebs_snapshot_id                        = var.ebs_snapshot_id
  friendly_name_prefix                   = var.friendly_name_prefix
  health_check_grace_period              = var.health_check_grace_period
  health_check_type                      = var.health_check_type
  instance_type                          = var.instance_type
  is_replicated_deployment               = var.is_replicated_deployment
  key_name                               = var.key_name
  network_id                             = local.network_id
  network_subnets_private                = local.network_private_subnets
  network_private_subnet_cidrs           = local.network_private_subnet_cidrs
  node_count                             = var.node_count
  user_data_base64                       = var.is_replicated_deployment ? module.tfe_init_replicated[0].tfe_userdata_base64_encoded : module.tfe_init_fdo[0].tfe_userdata_base64_encoded
}
