output "bastion_public_dns" {
  value = var.deploy_bastion == true ? aws_instance.bastion[0].public_dns : null
}

output "bastion_public_ip" {
  value = var.deploy_bastion == true ? aws_instance.bastion[0].public_ip : null
}

output "bastion_sg" {
  value = var.deploy_bastion == true ? aws_security_group.bastion[0].id : null
}

output "generated_bastion_key_public" {
  value = var.deploy_bastion == true ? aws_key_pair.generated_bastion_key.key_name : null
}

output "generated_bastion_key_private" {
  value = var.deploy_bastion == true ? tls_private_key.tfe_bastion.private_key_pem : null
}
