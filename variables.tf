# Common
# ------
variable "ami_id" {
  type        = string
  default     = ""
  description = "AMI ID to use for TFE instances"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN to use with load balancer"
}

variable "asg_tags" {
  type        = map(string)
  description = <<DESC
  (Optional) Map of tags only used for the autoscaling group. If you are using the AWS provider's default_tags,
  please note that it tags every taggable resource except for the autoscaling group, therefore this variable may
  be used to duplicate the key/value pairs in the default_tags if you wish.
  DESC
  default     = {}
}

variable "aws_access_key_id" {
  default     = null
  description = <<-EOD
  The identity of the access key which TFE will use to authenticate with S3. This value requires var.
  aws_secret_access_key and var.object_storage_iam_user to also be set.
  EOD
  type        = string
}

variable "aws_secret_access_key" {
  default     = null
  description = <<-EOD
  The secret access key which TFE will use to authenticate with S3. This value requires var.aws_secret_access_key and
  var.object_storage_iam_user to also be set.
  EOD
  type        = string
}

variable "object_storage_iam_user" {
  default     = null
  description = <<-EOD
  The IAM user that will be authorized to access the S3 storage bucket which holds Terraform Enterprise runtime data.
  This value requires var.aws_access_key_id and var.aws_secret_access_key to also be set. The values of those variables
  must represent an access key that is associated with this user.
  EOD
  type        = object({ arn = string })
}

variable "redis_cache_size" {
  type        = string
  default     = "cache.m4.large"
  description = "Redis instance size."
}

variable "redis_engine_version" {
  type        = string
  default     = "5.0.6"
  description = "Redis enginer version."
}

variable "redis_parameter_group_name" {
  type        = string
  default     = "default.redis5.0"
  description = "Redis parameter group name."
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

variable "postgres_engine_version" {
  type        = string
  default     = "12.8"
  description = "PostgreSQL version."
}

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "instance_type" {
  default     = "m5.xlarge"
  description = "The instance type of EC2 instance(s) to create."
  type        = string
}

# Network
# -------
variable "network_id" {
  default     = ""
  description = "The identity of the VPC in which resources will be deployed."
  type        = string
}

variable "network_private_subnets" {
  default     = []
  description = "A list of the identities of the private subnetworks in which resources will be deployed."
  type        = list(string)
}

variable "network_public_subnets" {
  default     = []
  description = "A list of the identities of the public subnetworks in which resources will be deployed."
  type        = list(string)
}

variable "deploy_vpc" {
  type        = bool
  description = "(Optional) Boolean indicating whether to deploy a VPC (true) or not (false)."
  default     = true
}

variable "network_cidr" {
  type        = string
  description = "(Optional) CIDR block for VPC."
  default     = "10.0.0.0/16"
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
  default     = ["10.0.32.0/20", "10.0.48.0/20"]
}

variable "network_public_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of public subnet CIDR ranges to create in VPC."
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "admin_dashboard_ingress_ranges" {
  type        = list(string)
  description = "(Optional) List of CIDR ranges that are allowed to acces the admin dashboard. Only used for standalone installations."
  default     = ["0.0.0.0/0"]
}

# TFE Instance(s)
# ---------------
variable "node_count" {
  type        = number
  default     = 2
  description = "The number of nodes you want in your autoscaling group (1 for standalone, 2 for active-active configuration)"

  validation {
    condition     = var.node_count <= 5
    error_message = "The node_count value must be less than or equal to 5."
  }
}

variable "ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
  description = "SSL policy to use on ALB listener"
}

variable "tfe_subdomain" {
  type        = string
  default     = "tfe"
  description = "Subdomain for accessing the Terraform Enterprise UI."
}

variable "iact_subnet_list" {
  default     = []
  description = "A list of CIDR masks that configure the ability to retrieve the IACT from outside the host."
  type        = list(string)
}

variable "iact_subnet_time_limit" {
  default     = 60
  description = "The time limit that requests from the subnets listed can request the IACT, as measured from the instance creation in minutes."
  type        = number
}

variable "iam_role_policy_arns" {
  default     = []
  description = "A set of Amazon Resource Names of IAM role policies to be attached to the TFE IAM role."
  type        = set(string)
}

variable "key_name" {
  default     = null
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

# KMS
# ---
variable "kms_key_alias" {
  type        = string
  description = "KMS key alias for AWS KMS Customer managed key."
  default     = "tfe-managed-kms"
}

variable "kms_key_deletion_window" {
  type        = number
  description = "(Optional) Duration in days to destroy the key after it is deleted. Must be between 7 and 30 days."
  default     = 7
}

# Secrets Manager
# ---------------

variable "tfe_license_secret" {
  type        = string
  description = "The Secrets Manager secret under which the Base64 encoded Terraform Enterprise license is stored."
}

variable "ca_certificate_secret" {
  default     = null
  type        = string
  description = <<-EOD
  A Secrets Manager secret which contains the Base64 encoded version of a PEM encoded public certificate of a
  certificate authority (CA) to be trusted by the EC2 instance(s). This argument
  is only required if TLS certificates in the deployment are not issued by a well-known CA.
  EOD
}

# Load Balancer
# -------------
variable "load_balancing_scheme" {
  default     = "PRIVATE"
  description = "Load Balancing Scheme. Supported values are: \"PRIVATE\"; \"PRIVATE_TCP\"; \"PUBLIC\"."
  type        = string

  validation {
    condition     = contains(["PRIVATE", "PRIVATE_TCP", "PUBLIC"], var.load_balancing_scheme)
    error_message = "The load_balancer value must be one of: \"PRIVATE\"; \"PRIVATE_TCP\"; \"PUBLIC\"."
  }
}

# PROXY SETTINGS
# --------------
variable "proxy_ip" {
  type        = string
  description = "(Optional) IP address of existing web proxy to route TFE traffic through."
  default     = ""
}

variable "no_proxy" {
  type        = list(string)
  description = "(Optional) List of IP addresses to not proxy"
  default     = []
}

# Redis
# -----
variable "redis_encryption_in_transit" {
  type        = bool
  description = "Determine whether Redis traffic is encrypted in transit."
  default     = false
}

variable "redis_encryption_at_rest" {
  type        = bool
  description = "Determine whether Redis data is encrypted at rest."
  default     = false
}

variable "redis_require_password" {
  type        = bool
  description = "Determine if a password is required for Redis."
  default     = false
}

# External Vault
# --------------
variable "extern_vault_enable" {
  default     = 0
  type        = number
  description = "(Optional) Indicate if an external Vault cluster is being used. Set to 1 if so."
}

variable "extern_vault_addr" {
  default     = null
  type        = string
  description = "(Required if var.extern_vault_enable = 1) URL of external Vault cluster."
}

variable "extern_vault_role_id" {
  default     = null
  type        = string
  description = "(Required if var.extern_vault_enable = 1) AppRole RoleId to use to authenticate with the Vault cluster."
}

variable "extern_vault_secret_id" {
  default     = null
  type        = string
  description = "(Required if var.extern_vault_enable = 1) AppRole SecretId to use to authenticate with the Vault cluster."
}

variable "extern_vault_path" {
  default     = "auth/approle"
  type        = string
  description = "(Optional) Path on the Vault server for the AppRole auth. Defaults to auth/approle."
}

variable "extern_vault_token_renew" {
  default     = 3600
  type        = number
  description = "(Optional) How often (in seconds) to renew the Vault token."
}

variable "extern_vault_namespace" {
  default     = null
  type        = string
  description = "(Optional) The Vault namespace"
}