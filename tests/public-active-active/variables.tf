variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "iact_subnet_list" {
  default     = []
  description = "A list of CIDR masks that configure the ability to retrieve the IACT from outside the host."
  type        = list(string)
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
  description = <<-EOD
  The name of the Secrets Manager secret ID of the Base64 encoded Terraform Enterprise license.
  EOD
}
