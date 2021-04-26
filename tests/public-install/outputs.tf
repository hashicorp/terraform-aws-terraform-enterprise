output "public_install" {
  value       = module.public_install
  description = "The output of all the public_install module."
}

output "health_check_url" {
  value       = module.public_install.health_check_url
  description = "The health check URL for TFE."
}
