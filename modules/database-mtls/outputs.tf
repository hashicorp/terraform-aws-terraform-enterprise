output "postgres_public_ip" {
  description = "Public IP of the EC2 instance running Postgres"
  value       = aws_instance.postgres.public_ip
}

output "endpoint" {
  value       = aws_instance.postgres.public_ip
  description = "The connection endpoint of the PostgreSQL RDS instance in address:port format."
}

output "name" {
  value       = var.db_name
  description = "The name of the PostgreSQL instance."
}

output "password" {
  value       = "postgres_postgres"
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

output "ca_certificate_secret_binary" {
  value       = data.aws_secretsmanager_secret_version.database_mtls_client_ca.secret_binary
  description = "The secret which contains the CA certificate."
  sensitive   = true
}
