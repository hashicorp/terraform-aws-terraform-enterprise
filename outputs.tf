# Bastion
output "bastion_public_dns" {
  value = module.bastion.bastion_public_dns

  description = "The public DNS name assigned to the bastion EC2 instance."
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip

  description = "The public IP address assigned to the bastion EC2 instance."
}

# KMS
output "kms_key_arn" {
  value = aws_kms_key.tfe_key.arn

  description = "The Amazon Resource Name of the KMS key used to encrypt data at rest."
}

output "kms_key_id" {
  value = aws_kms_key.tfe_key.key_id

  description = "The identity of the KMS key used to encrypt data at rest."
}

# Network
output "network_id" {
  value = module.networking.network_id

  description = "The identity of the VPC in which resources are deployed."
}

output "private_subnet_ids" {
  value = module.networking.network_private_subnets

  description = "The identities of the private subnetworks deployed within the VPC."
}

output "public_subnet_ids" {
  value = module.networking.network_public_subnets

  description = "The identities of the public subnetworks deployed within the VPC."
}

output "network_private_subnet_cidrs" {
  value = module.networking.network_private_subnet_cidrs

  description = "The CIDR blocks of the private subnetworks deployed within the VPC."
}

# Security Groups
output "tfe_instance_sg" {
  value = module.vm.tfe_instance_sg

  description = "The identity of the security group attached to the TFE EC2 instance."
}

# Secrets Manager
output "secretsmanager_secret_arn" {
  value = module.secrets_manager.secretsmanager_secret_arn

  description = "The Amazon Resource Name of the Secrets Manager secret."
}

# S3
output "bootstrap_bucket_name" {
  value = module.object_storage.s3_bucket_bootstrap

  description = "The name of the S3 bucket which contains TFE bootstrap artifacts."
}

output "bootstrap_bucket_arn" {
  value = module.object_storage.s3_bucket_bootstrap_arn

  description = "The Amazon Resource Name of the S3 bucket which contains TFE bootstrap artifacts."
}

# Load balancer
output "load_balancer_address" {
  value = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].load_balancer_address : module.load_balancer[0].load_balancer_address

  description = "The DNS name of the load balancer."
}

output "dns_configuration_notice" {
  value = "If you are using external DNS, please make sure to create a DNS record using the load_balancer_address output that has been provided"

  description = "A notice to inform users of how to configure an external DNS service to direct traffic to the load balancer."
}

output "login_url" {
  value       = "https://${local.fqdn}/admin/account/new?token=${module.user_data.user_token.value}"
  description = "Login URL to setup the TFE instance once it is initialized"
}
