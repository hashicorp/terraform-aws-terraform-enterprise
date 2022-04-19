variable "ca_certificate_secret_id" {
  type        = string
  description = <<-EOD
  A Secrets Manager secret which contains the Base64 encoded version of a PEM encoded public certificate of a
  certificate authority (CA) to be trusted by the EC2 instance.
  EOD
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "iam_role_policy_arns" {
  default     = []
  description = "A set of Amazon Resource Names of IAM role policys to be attached to the TFE IAM role."
  type        = set(string)
}

variable "enable_airgap" {
  type        = bool
  description = "If this is an airgapped installation, then the virtual machine will not need to have a role policy that allows it to access the secrets manager."
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key arn for AWS KMS Customer managed key."
}

variable "tfe_license_secret_id" {
  type        = string
  description = "The Secrets Manager secret under which the Base64 encoded Terraform Enterprise license is stored."
}

variable "vm_certificate_secret_id" {
  default     = null
  type        = string
  description = <<-EOD
  A Secrets Manager secret ARN which contains the Base64 encoded version of a PEM encoded public certificate for the Virtual
  Machine Scale Set.
  EOD
}

variable "vm_key_secret_id" {
  default     = null
  type        = string
  description = <<-EOD
  A Secrets Manager secret ARN which contains the Base64 encoded version of a PEM encoded private key for the Virtual Machine
  Scale Set.
  EOD
}