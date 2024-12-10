output "hostname" {
  value = aws_route53_record.sentinel.fqdn
}

output "redis_port" {
  value = var.redis_port
}

output "redis_sentinel_port" {
  value = var.redis_sentinel_port
}

output "redis_sentinel_leader_name" {
  value = var.redis_sentinel_leader_name
}

output "redis_sentinel_password" {
  value = var.redis_sentinel_password
}

output "password" {
  value = var.redis_password
}

output "use_password_auth" {
  value       = var.redis_use_password_auth ? true : false
  description = "A boolean which indicates if password authentication is required by the Redis"
}

output "use_tls" {
  value = var.use_tls ? true : false
}