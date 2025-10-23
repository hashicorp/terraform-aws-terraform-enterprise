# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "endpoint" {
  value       = aws_db_instance.postgresql.endpoint
  description = "The connection endpoint of the PostgreSQL RDS instance in address:port format."
}

output "name" {
  value       = aws_db_instance.postgresql.db_name
  description = "The name of the PostgreSQL RDS instance."
}

output "password" {
  value       = var.enable_iam_database_authentication ? null : aws_db_instance.postgresql.password
  description = "The password of the PostgreSQL user. Returns null when IAM authentication is enabled."
  sensitive   = true
}

output "username" {
  value       = var.enable_iam_database_authentication ? "${var.friendly_name_prefix}_iam_user" : aws_db_instance.postgresql.username
  description = "The name of the PostgreSQL user. Returns IAM user when IAM auth is enabled, otherwise the main database user."
}

output "parameters" {
  value       = var.db_parameters
  description = "PostgreSQL server parameters for the connection URI."
}
