output "random_pet_subdomain" {
  value = random_pet.subdomain.id

  description = "The subdomain name of the TFE deployment."
}

output "random_string_friendly_name" {
  value = local.complete_prefix

  description = "The combination of the provider prefix and a random component."
}

output "retailer_deployment" {
  value = module.retailer_deployment

  description = "The outputs of the root module."
}

output "retailer_proxy_public_address" {
  value = aws_instance.proxy.public_ip

  description = "The public IP address of the proxy EC2 instance."
}

output "retailer_proxy_private_address" {
  value = aws_instance.proxy.private_ip

  description = "The private IP address of the proxy EC2 instance."
}
