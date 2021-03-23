output "aws_elasticache_subnet_group_name" {
  value = var.active_active ? aws_elasticache_subnet_group.tfe[0].name : ""
}

output "aws_security_group_redis" {
  value = var.active_active ? aws_security_group.redis[0].id : ""
}

output "redis_endpoint" {
  value = var.active_active ? aws_elasticache_replication_group.redis[0].primary_endpoint_address : ""
}

output "redis_port" {
  value = var.active_active ? aws_elasticache_replication_group.redis[0].port : ""
}

output "redis_password" {
  value = (var.active_active == true && var.redis_require_password == true) ? random_id.redis_password[0].hex : ""
}

output "redis_use_password_auth" {
  value = (var.active_active == true && var.redis_require_password == true) ? true : false
}

output "redis_transit_encryption_enabled" {
  value = (var.active_active == true) ? aws_elasticache_replication_group.redis[0].transit_encryption_enabled : false
}
