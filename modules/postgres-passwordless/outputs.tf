# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "postgres_db_endpoint" {
  description = "The endpoint of the PostgreSQL instance."
  value       = aws_route53_record.postgres_db_dns.fqdn
}

output "postgres_db_sg_id" {
  description = "The security group ID for the PostgreSQL instance."
  value       = aws_security_group.postgres_db_sg.id
}

output "postgres_db_password" {
  description = "The password for the PostgreSQL instance."
  value       = random_string.postgres_db_password.result
  sensitive   = true
}
