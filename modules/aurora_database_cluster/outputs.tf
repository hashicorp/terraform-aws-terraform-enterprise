# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "endpoint" {
  value       = aws_rds_cluster.aurora_postgresql.endpoint
  description = "The connection endpoint of the PostgreSQL RDS instance in address:port format."
}

output "name" {
  value       = aws_rds_cluster.aurora_postgresql.database_name
  description = "The name of the PostgreSQL RDS instance."
}

output "password" {
  value       = var.aurora_db_password
  description = "The password of the main PostgreSQL user."
  sensitive   = true
}

output "username" {
  value       = aws_rds_cluster.aurora_postgresql.master_username
  description = "The name of the main PostgreSQL user."
}

output "parameters" {
  value       = var.db_parameters
  description = "PostgreSQL server parameters for the connection URI."
}

output "identifier" {
  value       = aws_rds_cluster.aurora_postgresql.cluster_identifier
  description = "The database identifier of the PostgreSQL Aurora cluster."
}

