variable "network_id" {
  description = <<-EOD
  The identity of the VPC in which the security group attached to the PostgreSQL RDS instance will be deployed.
  EOD
  type        = string
}

variable "db_size" {
  type        = string
  default     = "db.m4.xlarge"
  description = "PostgreSQL instance size."
}

variable "db_backup_retention" {
  type        = number
  description = "The days to retain backups for. Must be between 0 and 35"
  default     = 0
}

variable "db_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default     = null
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL version."
}

variable "monitoring_interval" {
  type        = number
  description = "Interval in seconds for monitoring of the RDS database. Any value other than null will enable enhanced monitoring."
  default     = null
}

variable "network_subnets_private" {
  description = <<-EOD
  A list of the identities of the private subnetworks in which the PostgreSQL RDS instance will be deployed.
  EOD
  type        = list(string)
}

variable "tfe_instance_sg" {
  description = <<-EOD
  The identity of the security group attached to the TFE EC2 instance(s), which will be authorized for communication with the PostgreSQL RDS instance.
  EOD
  type        = string
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
  default     = ["10.0.32.0/20", "10.0.48.0/20"]
}


variable "enabled_cloudwatch_logs" {
  type        = list(string)
  description = "List of enabled cloudwatch log export types. From list here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#enabled_cloudwatch_logs_exports"
  default     = null
  validation {
    condition     = var.enabled_cloudwatch_logs != null ? contains(["postgresql", "upgrade"], var.enabled_cloudwatch_logs) : true
    error_message = "Allowed cloudwatch log export types don't match allowed. Must be: postgresql, upgrade."
  }
}
