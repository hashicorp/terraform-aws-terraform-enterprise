variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "kms_key_arn" {}

variable "tfe_license_name" {
  type        = string
  default     = "ptfe-license.rli"
  description = "(Required) Filename for PTFE license file."
}

variable "tfe_license_filepath" {
  type        = string
  description = "(Required) Absolute filepath to location of PTFE license file."
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "proxy_cert_bundle_filepath" {}
variable "proxy_cert_bundle_name" {}
