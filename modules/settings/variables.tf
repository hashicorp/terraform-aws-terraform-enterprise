# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# --------------------------------------------------------------------------------------------
# NOTE: In the descriptions, there are many variables that state that they default to certain
# values, but the variable default is set to null. This is because this module will only add
# values to the final configuration that are set, and if they are left unset and null, then
# the TFE installation will use defaults set by the Replicated configuration for the TFE
# installation. You can find this documented here:
# https://www.terraform.io/enterprise/install/automated/automating-the-installer
# --------------------------------------------------------------------------------------------

# ------------------------------------------------------
# TFE
# ------------------------------------------------------
variable "backup_token" {
  default     = null
  type        = string
  description = "(Optional) This API token is used to access the backup/restore API within the product. If unset, it will default to the default_backup_token."
}

variable "capacity_concurrency" {
  default     = null
  type        = number
  description = "Number of concurrent plans and applies; defaults to 10."
}

variable "capacity_cpus" {
  default     = null
  type        = number
  description = "The maximum number of CPU cores that a Terraform plan or apply can use on the system; defaults to 0 (unlimited)."
}

variable "capacity_memory" {
  default     = null
  type        = number
  description = "The maximum amount of memory (in megabytes) that a Terraform plan or apply can use on the system; defaults to 512."
}

variable "custom_image_tag" {
  type        = string
  description = "(Required if tbw_image is 'custom_image'.) The name and tag for your alternative Terraform build worker image in the format <name>:<tag>. Default is 'hashicorp/build-worker:now'. If this variable is used, the 'tbw_image' variable must be 'custom_image'."
}

variable "custom_agent_image_tag" {
  type        = string
  description = "Configure the docker image for handling job execution within TFE. This can either be the standard image that ships with TFE or a custom image that includes extra tools not present in the default one. Should be in the format <name>:<tag>."
}

variable "production_type" {
  default     = "disk"
  type        = string
  description = "Where Terraform Enterprise application data will be stored. Valid values are `external`, `disk`, `active-active` or `null`. Choose `external` when storing application data in an external object storage service and database. Choose `disk` when storing application data in a directory on the Terraform Enterprise instance itself. Close `active-active` when deploying more than 1 node. Leave it `null` when you want Terraform Enterprise to use its own default."

  validation {
    condition     = contains(["external", "disk", "active-active"], var.production_type)
    error_message = "The production_type must be 'external', 'disk', `active-active`, or omitted."
  }
}

variable "release_sequence" {
  default     = null
  type        = number
  description = "Terraform Enterprise version release sequence. Pins the application to a release available in the license's channel, but is overridden by pins made in the vendor console. This setting is optional and has to be omitted when tfe_license_bootstrap_airgap_package_path is set."
}

# ------------------------------------------------------
# Log Forwarding and Metrics
# ------------------------------------------------------
variable "log_forwarding_enabled" {
  default     = null
  type        = bool
  description = "(Optional) Whether or not to enable log forwarding for Terraform Enterprise. Defaults to false."
}

variable "log_forwarding_config" {
  default     = null
  type        = string
  description = <<-EOD
  (Required when log_forwarding_enabled is true.) Valid log forwarding configuration specifying external
  destination(s) to forward logs. Defaults to:  # Example Fluent Bit configuration that matches all logs
  and does not # forward them anywhere.
  [OUTPUT]
      Name null
      Match *
  EOD
}

variable "metrics_endpoint_enabled" {
  default     = null
  type        = bool
  description = "(Optional) Metrics are used to understand the behavior of Terraform Enterprise and to troubleshoot and tune performance. Enable an endpoint to expose container metrics. Defaults to false."
}

variable "metrics_endpoint_port_http" {
  default     = null
  type        = number
  description = "(Optional when metrics_endpoint_enabled is true.) Defines the TCP port on which HTTP metrics requests will be handled. Defaults to 9090."
}

variable "metrics_endpoint_port_https" {
  default     = null
  type        = string
  description = "(Optional when metrics_endpoint_enabled is true.) Defines the TCP port on which HTTPS metrics requests will be handled. Defaults to 9091."
}

# ------------------------------------------------------
# Proxy
# ------------------------------------------------------
variable "extra_no_proxy" {
  default     = null
  type        = list(string)
  description = "When configured to use a proxy, a list of hosts to exclude from proxying. Please note that this list does not support whitespace characters."
}

# ------------------------------------------------------
# TLS
# ------------------------------------------------------
variable "tls_vers" {
  default     = null
  type        = string
  description = "(Optional) Set to tls_1_2 to enable only TLS 1.2, or to tls_1_3 to enable only TLS 1.3. Defaults to both TLS 1.2 and 1.3 (tls_1_2_tls_1_3)."

  validation {
    condition = (
      var.tls_vers == "tls_1_2_tls_1_3" ||
      var.tls_vers == "tls_1_2" ||
      var.tls_vers == "tls_1_3" ||
      var.tls_vers == null
    )
    error_message = "The tls_vers should be set to 'tls_1_2' to enable only TLS 1.2, to 'tls_1_3' to enable only TLS 1.3. When unset, TFE defaults this to both TLS 1.2 and 1.3 'tls_1_2_tls_1_3'."
  }
}

variable "tls_ciphers" {
  default     = null
  type        = string
  description = "(Optional) Set to an OpenSSL cipher list format string to enable a custom TLS ciphersuite. When unset, TFE uses a default ciphersuite."
}

variable "force_tls" {
  default     = null
  type        = bool
  description = "When set, TFE will require all application traffic to use HTTPS by sending a 'Strict-Transport-Security' header value in responses, and marking cookies as secure. A valid, trusted TLS certificate must be installed when this option is set, as browsers will refuse to serve webpages that have an HSTS header set that also serve self-signed or untrusted certificates."
}

# ------------------------------------------------------
# Replicated
# ------------------------------------------------------
variable "bypass_preflight_checks" {
  default     = null
  type        = bool
  description = "Allow the TFE application to start without preflight checks; defaults to false."
}

variable "hostname" {
  default     = null
  type        = string
  description = "(Required) The hostname you will use to access your installation."
}

variable "log_level" {
  default     = null
  type        = string
  description = "(Optional) If present, this will set the log level of the Replicated daemon."

  validation {
    condition = (
      var.log_level == "debug" ||
      var.log_level == "info" ||
      var.log_level == "error" ||
      var.log_level == null
    )
    error_message = "The log_level value must be one of: 'debug', 'info', 'error', or null."
  }
}

variable "tfe_license_bootstrap_airgap_package_path" {
  default     = null
  type        = string
  description = "(Optional) This is the location of the airgap bundle on the host. When set, the automated install will proceed as an airgapped installation. Note that tfe_license_file_location must also be set to the location of the matching airgap license."
}

variable "tfe_license_bootstrap_channel_id" {
  default     = null
  type        = string
  description = "(Optional) This variable allows specifying the installation channel for multi-channel licenses. When omitted and a multi-channel license is used, the release on the default channel will be installed."
}

variable "tfe_license_file_location" {
  default     = null
  type        = string
  description = "The path on the TFE instance to put the TFE license."
}

variable "tls_bootstrap_cert_pathname" {
  default     = null
  type        = string
  description = "The path on the TFE instance to put the certificate."
}

variable "tls_bootstrap_key_pathname" {
  default     = null
  type        = string
  description = "The path on the TFE instance to put the key."
}

# ------------------------------------------------------
# PostgreSQL Database
# ------------------------------------------------------
# If you have chosen external for production_type, the following settings apply:
variable "pg_user" {
  default     = null
  type        = string
  description = "(Required when production_type is 'external' or 'active-active') PostgreSQL user to connect as."
}

variable "pg_password" {
  default     = null
  type        = string
  description = "(Required when production_type is 'external' or 'active-active') The password for the PostgreSQL user."
}

variable "pg_netloc" {
  default     = null
  type        = string
  description = "(Required when production_type is 'external' or 'active-active') The hostname and port of the target PostgreSQL server, in the format hostname:port."
}

variable "pg_dbname" {
  default     = null
  type        = string
  description = "(Required when production_type is 'external' or 'active-active') The database name"
}

variable "pg_extra_params" {
  default     = null
  type        = string
  description = "(Optional) Parameter keywords of the form param1=value1&param2=value2 to support additional options that may be necessary for your specific PostgreSQL server. Allowed values are documented on the PostgreSQL site. An additional restriction on the sslmode parameter is that only the  require, verify-full, verify-ca, and disable values are allowed."
}

# ------------------------------------------------------
# Redis
# ------------------------------------------------------
variable "redis_host" {
  default     = null
  type        = string
  description = "(Required when production_type is 'active-active') Hostname of an external Redis instance which is resolvable from the TFE instance."
}

variable "redis_pass" {
  default     = null
  type        = string
  description = "The Primary Access Key for the Redis Instance. Must be set to the password of an external Redis instance if the instance requires password authentication."
}

variable "redis_use_password_auth" {
  default     = null
  type        = bool
  description = "Redis service requires a password."
}

variable "redis_use_tls" {
  default     = null
  type        = bool
  description = "Redis service requires TLS. If true, the external Redis instance will use port 6380, otherwise 6379."
}

variable "redis_use_mtls" {
  default     = null
  type        = bool
  description = "Redis service requires mutual TLS authentication. If true, the external Redis instance will use TLS certs for authentication."
}

# ------------------------------------------------------
# Mounted Disk
# ------------------------------------------------------
variable "disk_path" {
  default     = null
  type        = string
  description = "(Required when production_type is 'disk') Absolute path to a directory on the instance to store Terraform Enteprise data. Valid for mounted disk installations."
}

# ------------------------------------------------------
# AWS
# ------------------------------------------------------
variable "aws_access_key_id" {
  default     = null
  type        = string
  description = "AWS access key ID for S3 bucket access. To use AWSinstance profiles for this information, set it to ''."
}

variable "aws_secret_access_key" {
  default     = null
  type        = string
  description = "(Required when object storage is in AWS unless aws_access_key_id is set) AWS secret access key for S3 bucket access. To use AWS instance profiles for this information, set it to ''."
}

variable "s3_endpoint" {
  default     = null
  type        = string
  description = "(Optional when object storage is in AWS) Endpoint URL (hostname only or fully qualified URI). Usually only needed if using a VPC endpoint or an S3-compatible storage provider."
}

variable "s3_bucket" {
  default     = null
  type        = string
  description = "(Required when object storage is in AWS) The S3 bucket where resources will be stored"
}

variable "s3_region" {
  default     = null
  type        = string
  description = "(Required when object storage is in AWS) The region where the S3 bucket exists."
}

variable "s3_sse" {
  default     = null
  type        = string
  description = "(Optional when object storage is in AWS) Enables server-side encryption of objects in S3; if provided, must be set to aws:kms."
}

variable "s3_sse_kms_key_id" {
  default     = null
  type        = string
  description = "(Optional when object storage is in AWS) An optional KMS key for use when S3 server-side encryption is enabled."
}

# ------------------------------------------------------
# Azure
# ------------------------------------------------------
variable "azure_account_name" {
  default     = null
  type        = string
  description = "(Required when object storage is in Azure) The account name for the Azure account to access the container."
}

variable "azure_account_key" {
  default     = null
  type        = string
  description = "(Required when object storage is in Azure) The account key to access the account specified in azure_account_name."
}

variable "azure_container" {
  default     = null
  type        = string
  description = "(Required when object storage is in Azure) The identifer for the Azure blob storage container."
}

variable "azure_endpoint" {
  default     = null
  type        = string
  description = "(Optional when object storage is in Azure) The URL for the Azure cluster to use. By default this is the global cluster."
}

# ------------------------------------------------------
# Google
# ------------------------------------------------------
variable "gcs_bucket" {
  default     = null
  type        = string
  description = "(Required when object storage is in GCP) The GCP storage bucket name."
}

variable "gcs_credentials" {
  default     = null
  type        = string
  description = "JSON blob containing the GCP credentials document. This is only required if object storage is in GCP and the TFE instance(s) do(es) not have the service account attached to it, in which case the instance(s) may authenticate without credentials. Note: This is a string, so ensure values are properly escaped."
}

variable "gcs_project" {
  default     = null
  type        = string
  description = "(Required when object storage is in GCP) The GCP project where the bucket resides."
}

# ------------------------------------------------------
# External Vault
# ------------------------------------------------------
variable "extern_vault_enable" {
  default     = null
  type        = bool
  description = "(Optional) An external Vault cluster is being used."
}

variable "extern_vault_addr" {
  default     = null
  type        = string
  description = "(Required when extern_vault_enable is true) URL of external Vault cluster."
}

variable "extern_vault_role_id" {
  default     = null
  type        = string
  description = "(Required when extern_vault_enable is true) AppRole RoleId to use to authenticate with the Vault cluster."
}

variable "extern_vault_secret_id" {
  default     = null
  type        = string
  description = "(Required when extern_vault_enable is true) AppRole SecretId to use to authenticate with the Vault cluster."
}

variable "extern_vault_path" {
  default     = null
  type        = string
  description = "(Optional when extern_vault_enable is true) Path on the Vault server for the AppRole auth. Defaults to auth/approle."
}

variable "extern_vault_token_renew" {
  default     = null
  type        = number
  description = "(Optional when extern_vault_enable is true) How often (in seconds) to renew the Vault token. Defaults to 3600."
}

variable "extern_vault_propagate" {
  default     = null
  type        = bool
  description = "(Optional when extern_vault_enable is true) Propagate Vault credentials to Terraform workers. Defaults to false."
}

variable "extern_vault_namespace" {
  default     = null
  type        = string
  description = "(Optional when extern_vault_enable is true) The Vault namespace under which to operate. Defaults to ''."
}

# ------------------------------------------------------
# Advanced Configuration
# ------------------------------------------------------
# These are advanced configuration options that should not be changed without the direction
# of HashiCorp support personnel.

variable "iact_subnet_list" {
  default     = null
  type        = list(string)
  description = "A list of IP address ranges which will be authorized to access the IACT. The ranges must be expressed in CIDR notation, for example \"[\"10.0.0.0/24\"]\". If not set, no subnets can retrieve the IACT."
}

variable "iact_subnet_time_limit" {
  default     = null
  type        = string
  description = "(Optional if iact_subnet_list is not null.) To prevent an unconfigured instance from being discovered and hijacked by a rogue operator, IPs from the above subnet list are only allowed to access the retrieval API for a certain initial period of time. This setting defines that time period in minutes. Setting this to 'unlimited' will disable the time limit, although it is NOT recommended for production deployments. Defaults to '60'."
}

variable "hairpin_addressing" {
  default     = null
  type        = bool
  description = "In some cloud environments, HTTP clients running on instances behind a loadbalancer cannot send requests to the public hostname of that load balancer. Use this setting to configure TFE services to redirect requests for the installation's FQDN to the instance'sinternal IP address. Defaults to false."
}

variable "restrict_worker_metadata_access" {
  default     = null
  type        = bool
  description = "Prevents the environment where Terraform operations are executed from accessing the cloud instance metadata service. This should not be set when Terraform operations rely on using instance metadata (i.e., the instance IAM profile) as part of the Terraform provider configuration. NOTE: A bug in Docker version 19.03.3 prevents this setting from working correctly. Operators should avoid using this Docker version when enabling this setting. Defaults to false."
}

variable "trusted_proxies" {
  default     = null
  type        = list(string)
  description = "A list of CIDR masks, expressed as a comma-delimited string, which will be considered safe to ignore when evaluating the IP addresses of requests like those made to the IACT endpoint. This is relevant for situations like a client requesting the IACT through a load balancer which appends one or more X-Forwarded-For HTTP headers. For example: 10.0.1.0/24,172.16.4.0/24. By default the list is empty."
}
