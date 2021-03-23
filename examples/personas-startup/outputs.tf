output "random_pet_subdomain" {
  value = random_pet.subdomain.id
}

output "random_string_friendly_name" {
  value = "${var.prefix}-${random_string.friendly_name.result}"
}

output "startup_deployment" {
  value = module.startup_deployment
}
