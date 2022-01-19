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

variable "tfe_license_secret_name" {
  type        = string
  description = <<-EOD
  The name of the Secrets Manager secret under which the Base64 encoded Terraform Enterprise license is stored.
  EOD
}

variable "ca_certificate_secret_name" {
  type        = string
  description = <<-EOD
  The name of the Secrets Manager secret under which the Base64 encoded CA certificate is stored.
  EOD
}

variable "ca_private_key_secret_name" {
  type        = string
  description = <<-EOD
  The name of the Secrets Manager secret under which the Base64 encoded CA private key is stored.
  EOD
}
