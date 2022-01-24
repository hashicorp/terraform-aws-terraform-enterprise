variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "iam_role_policy_arns" {
  default     = []
  description = "A set of Amazon Resource Names of IAM role policys to be attached to the TFE IAM role."
  type        = set(string)
}

variable "ca_certificate_secret" {
  type        = string
  description = <<-EOD
  A Secrets Manager secret which contains the Base64 encoded version of a PEM encoded public certificate of a
  certificate authority (CA) to be trusted by the EC2 instance.
  EOD
}

variable "tfe_license_secret" {
  type        = string
  description = "The Secrets Manager secret under which the Base64 encoded Terraform Enterprise license is stored."
}
