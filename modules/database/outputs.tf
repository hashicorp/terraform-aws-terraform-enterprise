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
  value       = var.postgres_use_password_auth ? aws_db_instance.postgresql.password : ""
  description = "The password of the main PostgreSQL user."
}

output "username" {
  value       = aws_db_instance.postgresql.username
  description = "The name of the main PostgreSQL user."
}

output "parameters" {
  value       = var.db_parameters
  description = "PostgreSQL server parameters for the connection URI."
}

output "iam_user_setup_status" {
  value       = var.postgres_enable_iam_auth && var.db_iam_username != "" ? "IAM user automated creation enabled via null_resource and user_data fallback" : "IAM authentication not enabled"
  description = "Status of IAM user setup for PostgreSQL."
}

output "iam_database_name" {
  value       = var.postgres_enable_iam_auth ? "${var.db_iam_username}_db" : var.db_name
  description = "The name of the database for IAM authentication (separate database if IAM auth is enabled)."
}
