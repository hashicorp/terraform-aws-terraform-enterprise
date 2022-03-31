output "tfe_license_secret_id" {
  value = var.tfe_license == null ? null : aws_secretsmanager_secret_version.tfe_license[0].secret_id
}

output "ca_certificate_secret" {
  value = var.ca_certificate_secret == null ? {
    name      = null
    secret_id = null
    } : {
    name      = aws_secretsmanager_secret_version.ca_certificate_secret[0].name
    secret_id = aws_secretsmanager_secret_version.ca_certificate_secret[0].secret_id
  }
  description = "The AWS Secrets Manager secret which will be used for the ca_certificate_secret_id variable in the root module."
  sensitive   = true
}

output "ca_private_key_secret" {
  value = var.private_key_pem == null ? {
    name      = null
    secret_id = null
    } : {
    name      = aws_secretsmanager_secret_version.ca_private_key_secret[0].name
    secret_id = aws_secretsmanager_secret_version.ca_private_key_secret[0].secret_id
  }
  description = "The AWS Secrets Manager secret which will be used for the ca_private_key_secret_id variable in the test modules."
  sensitive   = true
}

output "certificate_pem_secret" {
  value = var.private_key_pem == null ? {
    name      = null
    secret_id = null
    } : {
    name      = aws_secretsmanager_secret_version.certificate_pem_secret[0].name
    secret_id = aws_secretsmanager_secret_version.certificate_pem_secret[0].secret_id
  }
  description = "The AWS Secrets Manager secret which will be used for the certificate_pem_secret_id variable in the root module."
  sensitive   = true
}

output "private_key_pem_secret" {
  value = var.private_key_pem == null ? {
    name      = null
    secret_id = null
    } : {
    name      = aws_secretsmanager_secret_version.private_key_pem_secret[0].name
    secret_id = aws_secretsmanager_secret_version.private_key_pem_secret[0].secret_id
  }
  description = "The AWS Secrets Manager secret which will be used for the private_key_pem_secret_id variable in the root module."
  sensitive   = true
}