# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "aws_elasticache_subnet_group_name" {
  value       = var.active_active ? aws_elasticache_subnet_group.tfe[0].name : ""
  description = "The name of the subnetwork group in which the Redis Elasticache replication group is deployed."
}

output "aws_security_group_redis" {
  value       = var.active_active ? aws_security_group.redis[0].id : ""
  description = "The identity of the security group attached to the Redis Elasticache replication group."
}

output "hostname" {
  value       = var.active_active ? aws_elasticache_replication_group.redis[0].primary_endpoint_address : ""
  description = "The IP address of the primary node in the Redis Elasticache replication group."
}

output "redis_port" {
  value       = var.active_active ? aws_elasticache_replication_group.redis[0].port : ""
  description = "The port number on which the Redis Elasticache replication group accepts connections."
}

output "password" {
  value       = try(random_id.redis_password[0].hex, "")
  description = "The password which is required to create connections with the Redis Elasticache replication group."
}

output "use_password_auth" {
  value       = var.active_active && var.redis_use_password_auth ? true : false
  description = "A boolean which indicates if password authentication is required by the Redis Elasticache replication group."
}

output "use_tls" {
  value       = var.active_active ? aws_elasticache_replication_group.redis[0].transit_encryption_enabled : false
  description = "A boolean which indicates if transit encryption is required by the Redis Elasticache replication group."
}
