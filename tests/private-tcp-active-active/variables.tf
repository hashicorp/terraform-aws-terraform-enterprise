variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
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

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "key_name" {
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

variable "license_file" {
  default     = null
  type        = string
  description = "The local path to the Terraform Enterprise license to be provided by CI."
}

variable "private_key_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS private key."
}

variable "tfe_license_secret_id" {
  default     = null
  type        = string
  description = "The secrets manager secret ID of the Base64 encoded Terraform Enterprise license."
}



