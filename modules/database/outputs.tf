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
  value = var.postgres_enable_iam_auth && var.db_iam_username != "" ? "SSM document created for PostgreSQL IAM user setup - requires manual execution on EC2 instance" : "IAM authentication not enabled"
  description = "Status of PostgreSQL IAM user setup"
}

output "postgres_iam_setup_ssm_document" {
  value = var.postgres_enable_iam_auth && var.db_iam_username != "" ? aws_ssm_document.postgres_iam_user_setup[0].name : null
  description = "SSM Document name for PostgreSQL IAM user setup (automated execution during instance startup)"
}
