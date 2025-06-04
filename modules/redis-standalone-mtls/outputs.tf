# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "hostname" {
  value       = ["${aws_route53_record.redis.fqdn}:${var.redis_port}"]
  description = "The host/port combinations for available Redis endpoint."
}

output "password" {
  value       = ""
  description = "The password which is required to authenticate to Redis server."
}

output "username" {
  value       = ""
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
  value       = ""
  description = "The host/port combinations for available Redis sentinel endpoints."
}

output "sentinel_leader" {
  value       = ""
  description = "The name of the Redis Sentinel leader"
}

output "sentinel_username" {
  value       = ""
  description = "the username to authenticate to Redis sentinel"
}

output "sentinel_password" {
  value       = ""
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
