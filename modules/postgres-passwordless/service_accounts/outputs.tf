# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "iam_instance_profile" {
  description = "The IAM instance profile that will be attached to the PostgreSQL EC2 instance."
  value       = local.iam_instance_profile
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile that will be attached to the PostgreSQL EC2 instance."
  value       = local.iam_instance_profile.name
}

output "iam_role" {
  description = "The IAM role associated with the PostgreSQL EC2 instance."
  value       = local.iam_instance_role
}

output "iam_role_name" {
  description = "The name of the IAM role associated with the PostgreSQL EC2 instance."
  value       = local.iam_instance_role.name
}