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
# KMS
# ---
variable "key_deletion_window" {
  description = "Duration in days to destroy the key after it is deleted. Must be between 7 and 30 days."
  type        = number
  default     = 7
}

