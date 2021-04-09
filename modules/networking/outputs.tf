output "bastion_host_subnet" {
  value = local.bastion_host_subnet

  description = "The identity of the public subnetwork in which the bastion EC2 instance will be deployed."
}

output "network_id" {
  value = local.network_id

  description = "The identity of the VPC in which resources will be delpoyed."
}

output "network_private_subnets" {
  value = aws_subnet.private[*].id

  description = "A list of the identities of the private subnetworks in which resources will be deployed."
}

output "network_public_subnets" {
  value = aws_subnet.public[*].id

  description = "A list of the identities of the public subnetworks in which resources will be deployed."
}

output "network_private_subnet_cidrs" {
  value = aws_subnet.private[*].cidr_block

  description = "A list of the CIDR blocks which comprise the private subnetworks."
}
