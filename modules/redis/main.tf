# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  redis_use_password_auth = var.redis_use_password_auth || var.redis_authentication_mode == "PASSWORD"
  redis_use_iam_auth      = var.redis_enable_iam_auth && !var.redis_use_password_auth
}

resource "random_id" "redis_password" {
  count       = var.active_active && local.redis_use_password_auth ? 1 : 0
  byte_length = 16
}

resource "aws_security_group" "redis" {
  count       = var.active_active ? 1 : 0
  description = "The security group of the Redis deployment for TFE."
  name        = "${var.friendly_name_prefix}-tfe-redis"
  vpc_id      = var.network_id
}

resource "aws_security_group_rule" "redis_tfe_ingress" {
  count                    = var.active_active ? 1 : 0
  security_group_id        = aws_security_group.redis[0].id
  type                     = "ingress"
  from_port                = var.redis_port
  to_port                  = var.redis_port
  protocol                 = "tcp"
  source_security_group_id = var.tfe_instance_sg
}

resource "aws_security_group_rule" "redis_tfe_egress" {
  count                    = var.active_active ? 1 : 0
  security_group_id        = aws_security_group.redis[0].id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.tfe_instance_sg
}

resource "aws_security_group_rule" "redis_ingress" {
  count             = var.active_active ? 1 : 0
  security_group_id = aws_security_group.redis[0].id
  type              = "ingress"
  from_port         = var.redis_port
  to_port           = var.redis_port
  protocol          = "tcp"
  cidr_blocks       = var.network_private_subnet_cidrs
}

resource "aws_security_group_rule" "redis_egress" {
  count             = var.active_active ? 1 : 0
  security_group_id = aws_security_group.redis[0].id
  type              = "egress"
  from_port         = var.redis_port
  to_port           = var.redis_port
  protocol          = "tcp"
  cidr_blocks       = var.network_private_subnet_cidrs
}

resource "aws_elasticache_subnet_group" "tfe" {
  count      = var.active_active ? 1 : 0
  name       = "${var.friendly_name_prefix}-tfe-redis"
  subnet_ids = var.network_subnets_private
}

# ElastiCache User for IAM authentication
resource "aws_elasticache_user" "iam_user" {
  count     = var.active_active && local.redis_use_iam_auth ? 1 : 0
  user_id   = "${var.friendly_name_prefix}-iam-user"
  user_name = "${var.friendly_name_prefix}-iam-user"

  # For IAM authentication, we don't set passwords but use IAM policies
  authentication_mode {
    type = "iam"
  }

  # Access string for Redis commands - allow all commands for TFE
  access_string = "on ~* &* +@all"
  engine        = "REDIS"

  tags = {
    Name = "${var.friendly_name_prefix}-redis-iam-user"
  }
}

# Default user required by ElastiCache user groups
resource "aws_elasticache_user" "default_user" {
  count     = var.active_active && local.redis_use_iam_auth ? 1 : 0
  user_id   = "default"
  user_name = "default"

  # Default user with no access - required for user group creation
  authentication_mode {
    type = "no-password-required"
  }

  # Deny all access for the default user since we're using IAM auth
  access_string = "off ~* &* -@all"
  engine        = "REDIS"

  tags = {
    Name = "${var.friendly_name_prefix}-redis-default-user"
  }
}

# ElastiCache User Group for IAM authentication
resource "aws_elasticache_user_group" "iam_group" {
  count         = var.active_active && local.redis_use_iam_auth ? 1 : 0
  engine        = "REDIS"
  user_group_id = "${var.friendly_name_prefix}-iam-group"
  user_ids = [
    aws_elasticache_user.default_user[0].user_id,
    aws_elasticache_user.iam_user[0].user_id
  ]

  tags = {
    Name = "${var.friendly_name_prefix}-redis-iam-group"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  count                = var.active_active ? 1 : 0
  node_type            = var.cache_size
  num_cache_clusters   = 1
  description          = "The replication group of the Redis deployment for TFE."
  replication_group_id = "${var.friendly_name_prefix}-tfe"

  apply_immediately          = true
  automatic_failover_enabled = false
  auto_minor_version_upgrade = true
  engine                     = "redis"
  engine_version             = var.engine_version
  parameter_group_name       = var.parameter_group_name
  port                       = var.redis_port
  security_group_ids         = [aws_security_group.redis[0].id]
  snapshot_retention_limit   = 0
  subnet_group_name          = aws_elasticache_subnet_group.tfe[0].name

  # Password used to access a password protected server.
  # Can be specified only if transit_encryption_enabled = true.
  auth_token                 = var.redis_encryption_in_transit && local.redis_use_password_auth ? random_id.redis_password[0].hex : null
  transit_encryption_enabled = var.redis_encryption_in_transit

  at_rest_encryption_enabled = var.redis_encryption_at_rest
  kms_key_id                 = var.redis_encryption_at_rest ? var.kms_key_arn : null

  # IAM authentication configuration
  user_group_ids = local.redis_use_iam_auth ? [aws_elasticache_user_group.iam_group[0].user_group_id] : null
}
