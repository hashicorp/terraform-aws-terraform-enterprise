# Bastion
output "bastion_public_dns" {
  value = module.bastion.bastion_public_dns
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

# KMS
output "kms_key_arn" {
  value = aws_kms_key.tfe_key.arn
}

output "kms_key_id" {
  value = aws_kms_key.tfe_key.key_id
}

# Network
output "network_id" {
  value = module.networking.network_id
}

output "private_subnet_ids" {
  value = module.networking.network_private_subnets
}

output "public_subnet_ids" {
  value = module.networking.network_public_subnets
}

output "network_private_subnet_cidrs" {
  value = module.networking.network_private_subnet_cidrs
}

# Security Groups
output "tfe_instance_sg" {
  value = module.vm.tfe_instance_sg
}

# Secrets Manager
output "secretsmanager_secret_arn" {
  value = module.secrets_manager.secretsmanager_secret_arn
}

# S3
output "bootstrap_bucket_name" {
  value = module.object_storage.s3_bucket_bootstrap
}

output "bootstrap_bucket_arn" {
  value = module.object_storage.s3_bucket_bootstrap_arn
}

# Load balancer
output "load_balancer_address" {
  value = var.load_balancing_scheme == "PRIVATE_TCP" ? module.private_tcp_load_balancer[0].load_balancer_address : module.load_balancer[0].load_balancer_address
}

output "dns_configuration_notice" {
  value = "If you are using external DNS, please make sure to create a DNS record using the load_balancer_address output that has been provided"
}

output "login_url" {
  value       = "https://${local.fqdn}/admin/account/new?token=${module.user_data.user_token.value}"
  description = "Login URL to setup the TFE instance once it is initialized"
}
