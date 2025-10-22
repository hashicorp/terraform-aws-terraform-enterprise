# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
output "hostname" {
  value       = var.active_active ? aws_elasticache_replication_group.redis[0].primary_endpoint_address : ""
  description = "The IP address of the primary node in the Redis Elasticache replication group."
}

output "password" {
  value       = try(random_id.redis_password[0].hex, "")
  description = "The password which is required to create connections with the Redis Elasticache replication group."
}

output "username" {
  value       = try(aws_elasticache_user.iam_user[0].user_name, null)
  description = "The username which is required to create connections with the Redis Elasticache replication group. Returns IAM username when IAM auth is enabled, otherwise null to maintain the output interface with the redis-sentinel module."
}

output "redis_port" {
  value       = var.active_active ? aws_elasticache_replication_group.redis[0].port : ""
  description = "The port number on which the Redis Elasticache replication group accepts connections."
}

output "use_password_auth" {
  value       = var.active_active && local.redis_use_password_auth ? true : false
  description = "A boolean which indicates if password authentication is required by the Redis Elasticache replication group."
}

output "use_tls" {
  value       = var.active_active ? aws_elasticache_replication_group.redis[0].transit_encryption_enabled : false
  description = "A boolean which indicates if transit encryption is required by the Redis Elasticache replication group."
}

output "sentinel_enabled" {
  value       = false
  description = "sentinel is not enabled"
}

output "sentinel_hosts" {
  value       = []
  description = "The host/port combinations for available Redis sentinel endpoints."
}

output "sentinel_leader" {
  value       = null
  description = "The name of the Redis Sentinel leader"
}

output "sentinel_username" {
  value       = null
  description = "the username to authenticate to Redis sentinel"
}

output "sentinel_password" {
  value       = null
  description = "the password to authenticate to Redis sentinel"
}

output "aws_elasticache_subnet_group_name" {
  value       = var.active_active ? aws_elasticache_subnet_group.tfe[0].name : ""
  description = "The name of the subnetwork group in which the Redis Elasticache replication group is deployed."
}

output "aws_security_group_redis" {
  value       = var.active_active ? aws_security_group.redis[0].id : ""
  description = "The identity of the security group attached to the Redis Elasticache replication group."
}
