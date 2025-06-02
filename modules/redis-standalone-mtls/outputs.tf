# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "hostname" {
  value       = ["${aws_route53_record.redis.fqdn}:${var.redis_port}"]
  description = "The host/port combinations for available Redis endpoint."
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

output "use_mtls" {
  value       = true
  description = "A boolean which indicates if mTLS is required by Redis server."
}
