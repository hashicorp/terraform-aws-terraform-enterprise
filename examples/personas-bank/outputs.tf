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

output "tfe_autoscaling_group_name" {
  value = module.bank_deployment.tfe_autoscaling_group.name

  description = "The name of the autoscaling group which hosts the TFE EC2 instance(s)."
}
