# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "replicated_configuration" {
  value       = local.replicated_configuration
  description = "The settings that will be used to configure Replicated."
}

output "tfe_configuration" {
  value       = local.tfe_configuration
  description = "The settings that will be used to configure Terraform Enterprise."
}