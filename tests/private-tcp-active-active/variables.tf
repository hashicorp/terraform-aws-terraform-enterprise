variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
}

variable "key_name" {
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

variable "tfe_license_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 encoded Terraform Enterprise license."
}

variable "ca_certificate_secret_name" {
  type        = string
  description = "The secrets manager secret name of the Base64 encoded CA certificate."
}

variable "ca_private_key_secret_name" {
  type        = string
  description = "The secrets manager secret name of the Base64 encoded CA private key."
}

variable "certificate_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate."
}

variable "private_key_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS private key."
}
