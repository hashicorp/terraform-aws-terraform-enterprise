# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "endpoint" {
  description = "The connection endpoint of the PostgreSQL instance in address:port format."
  value       = aws_route53_record.postgres_db_dns.fqdn
}

output "name" {
  description = "The name of the PostgreSQL instance."
  value       = var.db_name
}

output "password" {
  description = "The password of the main PostgreSQL user."
  value       = random_string.postgres_db_password.result
  sensitive   = true
}

output "username" {
  description = "The name of the main PostgreSQL user."
  value       = var.db_username
}

output "parameters" {
  description = "PostgreSQL server parameters for the connection URI."
  value       = var.db_parameters
}

# Legacy outputs for backward compatibility
output "postgres_db_endpoint" {
  description = "The endpoint of the PostgreSQL instance."
  value       = aws_route53_record.postgres_db_dns.fqdn
}

output "postgres_db_sg_id" {
  description = "The security group ID for the PostgreSQL instance."
  value       = aws_security_group.postgres_db_sg.id
}

output "postgres_db_password" {
  description = "The password for the PostgreSQL instance."
  value       = random_string.postgres_db_password.result
  sensitive   = true
}
