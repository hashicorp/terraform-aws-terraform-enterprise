output "bastion_host_subnet" {
  value = local.bastion_host_subnet
}

output "network_id" {
  value = local.network_id
}

output "network_private_subnets" {
  value = aws_subnet.private[*].id
}

output "network_public_subnets" {
  value = aws_subnet.public[*].id
}

output "network_private_subnet_cidrs" {
  value = aws_subnet.private[*].cidr_block
}
