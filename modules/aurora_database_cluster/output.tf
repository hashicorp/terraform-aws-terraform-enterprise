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
  value       = random_string.postgresql_password.result
  description = "The password of the main PostgreSQL user."
}

output "username" {
  value       = aws_rds_cluster.aurora_postgresql.master_username
  description = "The name of the main PostgreSQL user."
}

# The 'writer' endpoint for the cluster
output "cluster_endpoint" {
  value = join("", aws_rds_cluster.aurora_postgresql.*.endpoint)
}

# List of all DB instance endpoints running in cluster
# output "all_instance_endpoints_list" {
#   value = [concat(
#     aws_rds_cluster_instance.cluster_instance_0.*.endpoint,
#     aws_rds_cluster_instance.cluster_instance_n.*.endpoint,
#   )]
# }

# A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas
output "reader_endpoint" {
  value = join("", aws_rds_cluster.aurora_postgresql.*.reader_endpoint)
}

# The ID of the RDS Cluster
output "cluster_identifier" {
  value = join("", aws_rds_cluster.aurora_postgresql.*.id)
}

output "parameters" {
  value       = var.db_parameters
  description = "PostgreSQL server parameters for the connection URI."
}

