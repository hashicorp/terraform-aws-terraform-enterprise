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
  description = "The password of the PostgreSQL user (null when IAM auth is enabled)."
  sensitive   = true
}

output "username" {
  value       = var.enable_iam_database_authentication ? "${var.friendly_name_prefix}-iam-user" : aws_db_instance.postgresql.username
  description = "The name of the PostgreSQL user (IAM user when IAM auth is enabled, otherwise master user)."
}

output "iam_username" {
  value       = var.enable_iam_database_authentication ? "${var.friendly_name_prefix}-iam-user" : null
  description = "The name of the IAM-enabled PostgreSQL user."
}

output "parameters" {
  value       = var.db_parameters
  description = "PostgreSQL server parameters for the connection URI."
}
