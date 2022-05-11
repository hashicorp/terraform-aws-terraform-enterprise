variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
}

variable "hcp_vault_module_source" {
  type        = string
  default     = "git::https://github.com/hashicorp/terraform-random-tfe-utility//fixtures/test_hcp_vault?ref=main"
  description = "The value of the source argument for the hcp_vault module block."
}

variable "license_file" {
  type        = string
  description = "The local path to the Terraform Enterprise license to be provided by CI."
}