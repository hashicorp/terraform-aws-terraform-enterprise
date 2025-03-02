# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "sentinel_hosts" {
  value       = ["${aws_route53_record.sentinel.fqdn}:${var.redis_sentinel_port}"]
  description = "The host/port combinations for available Redis sentinel endpoints."
}

output "sentinel_leader" {
  value       = var.redis_sentinel_leader_name
  description = "The name of the Redis Sentinel leader"
}

output "sentinel_password" {
  value       = var.redis_sentinel_password
  description = "the password to authenticate to Redis sentinel"
}

output "sentinel_username" {
  value       = var.redis_sentinel_username
  description = "the username to authenticate to Redis sentinel"
}

output "hostname" {
  value       = null
  description = "The IP address of the primary node in the Redis Elasticache replication group."
}

output "redis_port" {
  value       = null
  description = "The port number on which the Redis Elasticache replication group accepts connections."
}

output "password" {
  value       = var.redis_password
  description = "The password which is required to authenticate to Redis server."
}

output "use_password_auth" {
  value       = var.redis_use_password_auth
  description = "A boolean which indicates if password authentication is required by the Redis server."
}

output "use_tls" {
  value       = false
  description = "A boolean which indicates if transit encryption is required by Redis server."
}
