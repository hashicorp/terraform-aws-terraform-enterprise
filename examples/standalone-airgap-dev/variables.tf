variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
}

variable "airgap_url" {
  description = "The URL of the storage bucket object that comprises an airgap package."
  type        = string
}

variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "certificate_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate for tfe"
}

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "iact_subnet_list" {
  default     = ["0.0.0.0/0"]
  type        = list(string)
  description = "A list of CIDR masks that configure the ability to retrieve the IACT from outside the host."
}

variable "license_file" {
  type        = string
  description = "The local path to the Terraform Enterprise license."
}

variable "private_key_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS private key for tfe"
}

variable "tags" {
  type        = map(string)
  description = <<DESC
  (Optional) Map of tags only used for the autoscaling group. If you are using the AWS provider's default_tags,
  please note that it tags every taggable resource except for the autoscaling group, therefore this variable may
  be used to duplicate the key/value pairs in the default_tags if you wish.
  DESC
  default     = {}
}

variable "tfe_subdomain" {
  type        = string
  description = "Subdomain for TFE"
}
