output "endpoint" {
  value       = aws_route53_record.postgres_db_dns.fqdn
  description = "The connection endpoint of the PostgreSQL RDS instance in address format."
}

output "name" {
  value       = var.db_name
  description = "The name of the PostgreSQL instance."
}

output "password" {
  value       = random_string.postgres_password.result
  description = "The password of the main PostgreSQL user."
}

output "username" {
  value       = var.db_username
  description = "The name of the main PostgreSQL user."
}

output "parameters" {
  value       = var.db_parameters
  description = "PostgreSQL server parameters for the connection URI."
}
