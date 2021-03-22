output "random_pet_subdomain" {
  value = random_pet.subdomain.id
}

output "random_string_friendly_name" {
  value = local.complete_prefix
}

output "bank_deployment" {
  value = module.bank_deployment
}
