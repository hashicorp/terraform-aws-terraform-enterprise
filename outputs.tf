# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Network
output "network_id" {
  value       = local.network_id
  description = "The identity of the VPC in which resources are deployed."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}

output "private_subnet_ids" {
  value       = local.network_private_subnets
  description = "The identities of the private subnetworks deployed within the VPC."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}

output "public_subnet_ids" {
  value       = local.network_public_subnets
  description = "The identities of the public subnetworks deployed within the VPC."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}

output "network_private_subnet_cidrs" {
  value       = local.network_private_subnet_cidrs
  description = "The CIDR blocks of the private subnetworks deployed within the VPC."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}

# Security Groups
output "tfe_instance_sg" {
  value       = module.vm.tfe_instance_sg
  description = "The identity of the security group attached to the TFE EC2 instance."
}

# Load balancer
output "load_balancer_address" {
  value       = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].load_balancer_address : module.load_balancer[0].load_balancer_address
  description = "The DNS name of the load balancer."
}

output "dns_configuration_notice" {
  value       = "If you are using external DNS, please make sure to create a DNS record using the load_balancer_address output that has been provided"
  description = "A notice to inform users of how to configure an external DNS service to direct traffic to the load balancer."
}

output "health_check_url" {
  value       = "https://${local.fqdn}/_health_check"
  description = "The URL of the Terraform Enterprise health check endpoint."
}

output "login_url" {
  value       = var.is_replicated_deployment ? "https://${local.fqdn}/admin/account/new?token=${module.settings[0].tfe_configuration.user_token.value}" : "On the TFE instance, retrieve the IACT Token with `docker exec -t terraform-enterprise-tfe-1 /bin/bash -c /usr/local/bin/retrieve-iact` and then navigate to https://${local.fqdn}/admin/account/new?token=<IACT_TOKEN>."
  description = "Login URL to setup the TFE instance once it is initialized"
}

output "replicated_console_url" {
  value       = var.is_replicated_deployment ? "https://${local.fqdn}:8800/" : "FDO deployments do not have a console."
  description = "The URL of the Terraform Enterprise Replicated administration console."
}

output "tfe_url" {
  value       = "https://${local.fqdn}"
  description = "The URL to the TFE application."
}

output "tfe_autoscaling_group" {
  value = module.vm.tfe_autoscaling_group

  description = "The autoscaling group which hosts the TFE EC2 instance(s)."
  # This output is marked as sensitive to work around a bug in Terraform 0.14
  sensitive = true
}

output "replicated_dashboard_password" {
  value       = var.is_replicated_deployment ? module.settings[0].replicated_configuration.DaemonAuthenticationPassword : "This is only used for replicated deployments."
  description = "The password for the TFE console"
  sensitive   = true
}

output "key" {
  value       = data.aws_kms_key.main.id
  description = "The KMS key used to encrypt data."
}

output "s3_bucket" {
  value = local.object_storage.s3_bucket
  description = "S3 bucket name"
}
