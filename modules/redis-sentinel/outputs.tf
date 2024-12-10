output "hostname" {
  value = aws_route53_record.sentinel.fqdn
  description = "The hostname of the Redis Sentinel"
}

output "redis_port" {
  value = var.redis_port
  description = "The port of the Redis"
}

output "redis_sentinel_port" {
  value = var.redis_sentinel_port
  description = "The port of the Redis Sentinel"
}

output "redis_sentinel_leader_name" {
  value = var.redis_sentinel_leader_name
  description = "The name of the Redis Sentinel leader"
}

output "redis_sentinel_password" {
  value = var.redis_sentinel_password
  description = "value of the Redis Sentinel password"
}

output "password" {
  value = var.redis_password
  description = "value of the Redis password"
}

output "use_password_auth" {
  value       = var.redis_use_password_auth ? true : false
  description = "A boolean which indicates if password authentication is required by the Redis"
}

output "use_tls" {
  value = var.use_tls ? true : false
  description = "A boolean which indicates if TLS is required by the Redis"
}