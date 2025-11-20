# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "endpoint" {
  value       = aws_instance.edb_server.private_ip
  description = "The connection endpoint of the PostgreSQL RDS instance in address:port format."
}

output "name" {
  value       = "hashicorp"
  description = "The name of the PostgreSQL RDS instance."
}

output "password" {
  value       = "hashicorp"
  description = "The password of the main PostgreSQL user."
  sensitive   = true
}

output "username" {
  value       = "hashicorp"
  description = "The name of the main PostgreSQL user."
}

output "parameters" {
  value       = var.db_parameters
  description = "PostgreSQL server parameters for the connection URI."
}

output "iam_user_setup_status" {
  value       = "EDB does not support IAM authentication - using standard authentication"
  description = "Status of PostgreSQL IAM user setup"
}

output "postgres_iam_setup_ssm_document" {
  value       = null
  description = "SSM Document information for PostgreSQL IAM user setup (manual execution required)"
}
# Type fix verification
