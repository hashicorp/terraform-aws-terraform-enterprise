variable "friendly_name_prefix" {
  description = "The friendly name prefix which will be used for tagging and naming the Secrets Manager secret."
  type        = string
}

variable "common_tags" {
  type        = map(string)
  description = <<DESC
  (Optional) Map of common tags for AWS resources. If you are using the AWS provider's default_tags which
  tags every taggable resource, then every resource using this variable will be tagged with both default_tags
  and this map value.
  DESC
  default     = {}
}

variable "deploy_secretsmanager" {
  type        = bool
  description = "(Optional) Boolean indicating whether to deploy AWS Secrets Manager secret (true) or not (false)."
  default     = true
}

variable "secretsmanager_secret_name" {
  type        = string
  description = "(Optional) Name of AWS Secrets Manager secret metadata. Only specify if deploy_secretsmanager is true (this value will be auto-generated if left unspecified and deploy_secretsmanager is true)."
  default     = null
}

variable "secretsmanager_secrets" {
  type        = map(string)
  description = "(Optional) Map of key/value pairs of TFE install secrets. Only specify if deploy_secretsmanager is true."
  default     = null
}
