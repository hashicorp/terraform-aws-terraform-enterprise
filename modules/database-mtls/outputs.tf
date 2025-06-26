output "postgres_public_ip" {
  description = "Public IP of the EC2 instance running Postgres"
  value       = aws_instance.postgres.public_ip
}

output "postgres_domain_name" {
  value       = aws_route53_record.postgres.fqdn
  description = "The host/port combinations for available Redis endpoint."
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

# output "ca_certificate_secret_binary" {
#   value       = base64encode(data.local_file.ca_cert.content)
#   description = "The secret which contains the CA certificate."
#   sensitive   = true
# }
# output "ca_certificate_secret_binary" {
#   value       = aws_secretsmanager_secret.database_mtls_client_ca.name
#   description = "The secret which contains the CA certificate."
# }
