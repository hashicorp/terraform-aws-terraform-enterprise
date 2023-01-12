variable "aws_access_key_id" {
  type        = string
  description = "The identity of the access key which TFE will use to provision resources and authenticate with S3."
}

variable "aws_secret_access_key" {
  type        = string
  description = "The secret access key which TFE will use to provision resources and authenticate with S3."
}

variable "aws_session_token" {
  type        = string
  description = "The session token which TFE will used to provision resources."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
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

variable "key_name" {
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

variable "license_file" {
  default     = null
  type        = string
  description = "The local path to the Terraform Enterprise license to be provided by CI."
}

variable "tfe_license_secret_id" {
  default     = null
  type        = string
  description = <<-EOD
  The name of the Secrets Manager secret ID of the Base64 encoded Terraform Enterprise license.
  EOD
}
