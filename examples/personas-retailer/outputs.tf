output "random_pet_subdomain" {
  value = random_pet.subdomain.id
}

output "random_string_friendly_name" {
  value = local.complete_prefix
}

output "retailer_deployment" {
  value = module.retailer_deployment
}

output "retailer_proxy_public_address" {
  value = aws_instance.proxy.public_ip
}

output "retailer_proxy_private_address" {
  value = aws_instance.proxy.private_ip
}
