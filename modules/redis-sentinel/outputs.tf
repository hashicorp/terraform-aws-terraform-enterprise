# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "hostname" {
  value       = null
  description = "The IP address of the primary node in the Redis Elasticache replication group."
}

output "redis_password" {
  value       = local.redis_password
  description = "The password which is required to authenticate to Redis server."
}

output "redis_username" {
  value       = local.redis_username
  description = "The username which is required to authenticate to Redis server."
}

output "redis_port" {
  value       = null
  description = "The port number on which the Redis Elasticache replication group accepts connections."
}

output "use_password_auth" {
  value       = var.redis_use_password_auth
  description = "A boolean which indicates if password authentication is required by the Redis server."
}

output "use_tls" {
  value       = false
  description = "A boolean which indicates if transit encryption is required by Redis server."
}

output "sentinel_enabled" {
  value       = true
  description = "sentinel is enabled"
}

output "sentinel_hosts" {
  value       = ["${aws_route53_record.sentinel.fqdn}:${var.redis_sentinel_port}"]
  description = "The host/port combinations for available Redis sentinel endpoints."
}

output "sentinel_leader" {
  value       = var.sentinel_leader
  description = "The name of the Redis Sentinel leader"
}

output "sentinel_username" {
  value       = local.sentinel_username
  description = "the username to authenticate to Redis sentinel"
}

output "sentinel_password" {
  value       = local.sentinel_password
  description = "the password to authenticate to Redis sentinel"
}

output "aws_elasticache_subnet_group_name" {
  value       = ""
  description = "The name of the subnetwork group in which the Redis Elasticache replication group is deployed."
}

output "aws_security_group_redis" {
  value       = ""
  description = "The identity of the security group attached to the Redis Elasticache replication group."
}
