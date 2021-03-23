output "bastion_userdata_base64_encoded" {
  value = base64encode(local.bastion_user_data)
}

output "replicated_dashboard_password" {
  value = random_string.password.result
}

output "tfe_userdata_base64_encoded" {
  value = base64encode(local.tfe_user_data)
}

output "user_token" {
  value = local.base_configs.user_token
}
