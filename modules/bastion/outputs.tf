output "bastion_public_dns" {
  value = var.deploy_bastion == true ? aws_instance.bastion[0].public_dns : null

  description = "The public DNS name of the bastion EC2 instance."
}

output "bastion_public_ip" {
  value = var.deploy_bastion == true ? aws_instance.bastion[0].public_ip : null

  description = "The public IP address of the bastion EC2 instance."
}

output "bastion_sg" {
  value = var.deploy_bastion == true ? aws_security_group.bastion[0].id : null

  description = "The identity of the security group attached to the bastion EC2 instance."
}

output "generated_bastion_key_public" {
  value = var.deploy_bastion == true ? aws_key_pair.generated_bastion_key.key_name : null

  description = "The name of the SSH key pair associated with the bastion EC2 instance."
}

output "generated_bastion_key_private" {
  value = var.deploy_bastion == true ? tls_private_key.tfe_bastion.private_key_pem : null

  description = "The PEM formatted private data of the SSH key pair associated with the bastion EC2 instance."
}
