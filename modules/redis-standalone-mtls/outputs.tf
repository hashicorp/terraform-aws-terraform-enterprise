# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "hostname" {
  value       = null
  description = "The IP address of the primary node in the Redis Elasticache replication group."
}

output "redis_port" {
  value       = null
  description = "The port number on which the Redis Elasticache replication group accepts connections."
}

output "use_password_auth" {
  value       = false
  description = "A boolean which indicates if password authentication is required by the Redis server."
}

output "use_tls" {
  value       = false
  description = "A boolean which indicates if transit encryption is required by Redis server."
}

output "aws_elasticache_subnet_group_name" {
  value       = ""
  description = "The name of the subnetwork group in which the Redis Elasticache replication group is deployed."
}

output "aws_security_group_redis" {
  value       = ""
  description = "The identity of the security group attached to the Redis Elasticache replication group."
}
