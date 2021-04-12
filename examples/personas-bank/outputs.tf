output "random_pet_subdomain" {
  value = random_pet.subdomain.id

  description = "The subdomain name of the TFE deployment."
}

output "random_string_friendly_name" {
  value = local.complete_prefix

  description = "The combination of the provider prefix and a random component."
}

output "bank_deployment" {
  value = module.bank_deployment

  description = "The outputs of the root module."
}
