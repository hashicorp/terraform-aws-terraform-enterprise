variable "domain_name" {}

variable "admin_dashboard_ingress_ranges" {}

variable "certificate_arn" {}

variable "fqdn" {}

variable "ssl_policy" {}

variable "network_id" {}

variable "network_private_subnets" {}

variable "active_active" {
  type        = bool
  description = "Flag for active-active configuation: true for active-active, false for standalone."
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}
