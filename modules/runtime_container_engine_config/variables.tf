# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "azure_account_key" {
  default     = null
  type        = string
  description = "Azure Blob Storage access key. Required when TFE_OBJECT_STORAGE_TYPE is azure and TFE_OBJECT_STORAGE_AZURE_USE_MSI is false."
}

variable "azure_account_name" {
  default     = null
  type        = string
  description = "Azure Blob Storage account name. Required when TFE_OBJECT_STORAGE_TYPE is azure."
}

variable "azure_container" {
  default     = null
  type        = string
  description = "Azure Blob Storage container name. Required when TFE_OBJECT_STORAGE_TYPE is azure."
}

variable "azure_endpoint" {
  default     = null
  type        = string
  description = "Azure Storage endpoint. Useful if using a private endpoint for Azure Stoage. Leave blank to use the default Azure Storage endpoint. Defaults to \"\" if no value is given. "
}

variable "capacity_concurrency" {
  type        = number
  description = "Maximum number of Terraform runs that can execute concurrently on each Terraform Enterprise node. Defaults to 10 if no value is given."
}

variable "capacity_cpu" {
  type        = number
  description = "Maximum number of CPU cores a Terraform run is allowed to use. Set to 0 for no limit. Defaults to 0."
}

variable "capacity_memory" {
  type        = number
  description = "Maximum amount of memory (MiB) a Terraform run is allowed to use. Defaults to 2048 if no value is given."
}

variable "cert_file" {
  type        = string
  description = "Path to a file containing the TLS certificate Terraform Enterprise will use when serving TLS connections to clients."
}

variable "database_host" {
  type        = string
  description = "The PostgreSQL server to connect to in the format HOST[:PORT] (e.g. db.example.com or db.example.com:5432). If only HOST is provided then the :PORT defaults to :5432 if no value is given. Required when TFE_OPERATIONAL_MODE is external or active-active."
}

variable "database_name" {
  type        = string
  description = "Name of the PostgreSQL database to store application data in. Required when TFE_OPERATIONAL_MODE is external or active-active."
}

variable "database_parameters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection (e.g. sslmode=require)."
}

variable "database_password" {
  type        = string
  description = "PostgreSQL password. Required when TFE_OPERATIONAL_MODE is external or active-active."
}

variable "database_user" {
  type        = string
  description = "PostgreSQL user. Required when TFE_OPERATIONAL_MODE is external or active-active."
}

variable "database_ca_cert_file" {
  type        = string
  description = "Path to a file containing the CA certificate for Database TLS connections. Leave blank to not use a CA certificate for Database TLS connections. Defaults to \"\" if no value is given."
  default     = null
}

variable "database_client_cert_file" {
  type        = string
  description = "Path to a file containing the client certificate for Database TLS connections. Leave blank to not use a client certificate for Database TLS connections. Defaults to \"\" if no value is given."
  default     = null
}

variable "database_client_key_file" {
  type        = string
  description = "Path to a file containing the client key for Database TLS connections. Leave blank to not use a client key for Database TLS connections. Defaults to \"\" if no value is given."
  default     = null
}

variable "database_use_mtls" {
  type        = bool
  description = "Whether or not to use mutual TLS to access database. Defaults to false if no value is given."
  default     = false
}

variable "database_passwordless_azure_use_msi" {
  default     = false
  type        = bool
  description = "Whether or not to use Azure Managed Service Identity (MSI) to connect to the PostgreSQL database. Defaults to false if no value is given."
}

variable "database_passwordless_azure_client_id" {
  default     = ""
  type        = string
  description = "Azure Managed Service Identity (MSI) Client ID. If not set, System Assigned Managed Identity will be used."
}

variable "database_passwordless_aws_use_iam" {
  default     = false
  type        = bool
  description = "Whether or not to use AWS IAM authentication to connect to the PostgreSQL database. Defaults to false if no value is given."
}

variable "database_passwordless_aws_region" {
  default     = ""
  type        = string
  description = "AWS region for IAM database authentication. Required when database_passwordless_aws_use_iam is true."
}

variable "explorer_database_host" {
  type        = string
  default     = null
  description = "The PostgreSQL server to connect to in the format HOST[:PORT] (e.g. db.example.com or db.example.com:5432). If only HOST is provided then the :PORT defaults to :5432 if no value is given. Required when TFE_OPERATIONAL_MODE is external or active-active."
}

variable "explorer_database_name" {
  type        = string
  default     = null
  description = "Name of the PostgreSQL database to store application data in. Required when TFE_OPERATIONAL_MODE is external or active-active."
}

variable "explorer_database_parameters" {
  type        = string
  default     = null
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection (e.g. sslmode=require)."
}

variable "explorer_database_password" {
  type        = string
  default     = null
  description = "PostgreSQL password. Required when TFE_OPERATIONAL_MODE is external or active-active."
}

variable "explorer_database_user" {
  type        = string
  default     = null
  description = "PostgreSQL user. Required when TFE_OPERATIONAL_MODE is external or active-active."
}

variable "disk_path" {
  default     = null
  description = "The pathname of the directory in which Terraform Enterprise will store data in Mounted Disk mode. Required when var.operational_mode is 'disk'."
  type        = string
}

variable "enable_sentinel_mtls" {
  type        = bool
  description = "Whether or not to use mutual TLS to access Redis Sentinel. Defaults to false if no value is given."
  default     = false
}

variable "http_port" {
  default     = null
  type        = number
  description = "Port application listens on for HTTP. Default is 80."
}

variable "https_port" {
  default     = null
  type        = number
  description = "Port application listens on for HTTPS. Default is 443."
}

variable "admin_api_https_port" {
  default     = 8443
  type        = number
  description = "Port application listens on for Admin API. Default is 8443."
}

variable "iact_subnets" {
  type        = string
  description = "Comma-separated list of subnets in CIDR notation that are allowed to retrieve the initial admin creation token via the API (e.g. 10.0.0.0/8,192.168.0.0/24). Leave blank to disable retrieving the initial admin creation token via the API from outside the host. Defaults to \"\" if no value is given."
}

variable "iact_time_limit" {
  type        = number
  description = "Number of minutes that the initial admin creation token can be retrieved via the API after the application starts. Defaults to 60 if no value is given."
}

variable "google_bucket" {
  default     = null
  type        = string
  description = "Google Cloud Storage bucket name. Required when TFE_OBJECT_STORAGE_TYPE is google."
}

variable "google_credentials" {
  default     = null
  type        = string
  description = "Google Cloud Storage JSON credentials. Must be given as an escaped string of JSON or Base64 encoded JSON. Leave blank to use the attached service account. Defaults to \"\" if no value is given."
}

variable "google_project" {
  default     = null
  type        = string
  description = "Google Cloud Storage project name. Required when TFE_OBJECT_STORAGE_TYPE is google."
}

variable "hostname" {
  type        = string
  description = "Hostname where Terraform Enterprise is accessed (e.g. terraform.example.com)."
}

variable "http_proxy" {
  type        = string
  description = "(Optional) The IP address and port of existing web proxy to route TFE http traffic through."
  default     = null
}

variable "https_proxy" {
  type        = string
  description = "(Optional) The IP address and port of existing web proxy to route TFE https traffic through."
  default     = null
}

variable "license_reporting_opt_out" {
  type        = bool
  default     = false
  description = "Whether to opt out of reporting licensing information to HashiCorp. Defaults to false if no value is given."
}

variable "usage_reporting_opt_out" {
  type        = bool
  default     = false
  description = "Whether to opt out of TFE usage reporting to HashiCorp. Defaults to false if no value is given."
}

variable "key_file" {
  type        = string
  description = "Path to a file containing the TLS private key Terraform Enterprise will use when serving TLS connections to clients."
}

variable "metrics_endpoint_enabled" {
  default     = false
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


variable "no_proxy" {
  type        = list(string)
  description = "(Optional) List of IP addresses to not proxy"
  default     = []
}

variable "operational_mode" {
  type        = string
  description = "Terraform Enterprise operational mode."
  validation {
    condition = (
      var.operational_mode == "disk" ||
      var.operational_mode == "external" ||
      var.operational_mode == "active-active"
    )

    error_message = "Supported values for operational_mode are 'disk', 'external', and 'active-active'."
  }
}

variable "redis_host" {
  type        = string
  description = "The Redis server to connect to in the format HOST[:PORT] (e.g. redis.example.com or redis.example.com:). If only HOST is provided then the :PORT defaults to :6379 if no value is given. Required when TFE_OPERATIONAL_MODE is active-active."
}

variable "redis_password" {
  type        = string
  description = "Redis server password. Required when TFE_REDIS_USE_AUTH is true."
}

variable "redis_use_auth" {
  type        = bool
  description = "Whether or not to use authentication to access Redis. Defaults to false if no value is given."
}

variable "redis_use_tls" {
  type        = bool
  description = "Whether or not to use TLS to access Redis. Defaults to false if no value is given."
}

variable "redis_ca_cert_path" {
  type        = string
  description = "Path to a file containing the CA certificate for Redis TLS connections. Leave blank to not use a CA certificate for Redis TLS connections. Defaults to \"\" if no value is given."
  default     = null
}
variable "redis_client_cert_path" {
  type        = string
  description = "Path to a file containing the client certificate for Redis TLS connections. Leave blank to not use a client certificate for Redis TLS connections. Defaults to \"\" if no value is given."
  default     = null
}

variable "redis_client_key_path" {
  type        = string
  description = "Path to a file containing the client key for Redis TLS connections. Leave blank to not use a client key for Redis TLS connections. Defaults to \"\" if no value is given."
  default     = null
}

variable "redis_use_mtls" {
  type        = bool
  description = "Whether or not to use mutual TLS to access Redis. Defaults to false if no value is given."
  default     = false
}

variable "redis_user" {
  type        = string
  description = "Redis server user. Leave blank to not use a user when authenticating. Defaults to \"\" if no value is given."
}

variable "redis_use_sentinel" {
  type        = bool
  description = "Will connections to redis use the sentinel protocol?"
  default     = false
}

variable "redis_sentinel_hosts" {
  type        = list(string)
  description = "A list of sentinel host/port combinations in the form of 'host:port', eg: sentinel-leader.terraform.io:26379"
  default     = []
}

variable "redis_sentinel_leader_name" {
  type        = string
  description = "The name of the sentinel leader."
  default     = null
}

variable "redis_sentinel_user" {
  type        = string
  description = "Redis sentinel user. Leave blank to not use a user when authenticating to redis sentinel. Defaults to \"\" if no value is given."
  default     = null
}

variable "redis_sentinel_password" {
  type        = string
  description = "Redis senitnel password."
  default     = null
}

variable "redis_passwordless_azure_use_msi" {
  default     = false
  type        = bool
  description = "Whether or not to use Azure Managed Service Identity (MSI) to connect to the Redis server. Defaults to false if no value is given."
}

variable "redis_passwordless_azure_client_id" {
  default     = ""
  type        = string
  description = "Azure Managed Service Identity (MSI) Client ID to be used for redis authentication. If not set, System Assigned Managed Identity will be used."
}

variable "run_pipeline_image" {
  type        = string
  description = "Container image used to execute Terraform runs. Leave blank to use the default image that comes with Terraform Enterprise. Defaults to \"\" if no value is given."
}

variable "s3_access_key_id" {
  default     = null
  type        = string
  description = "S3 access key ID. Required when TFE_OBJECT_STORAGE_TYPE is s3 and TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE is false."
}

variable "s3_secret_access_key" {
  default     = null
  type        = string
  description = "S3 secret access key. Required when TFE_OBJECT_STORAGE_TYPE is s3 and TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE is false."

}

variable "s3_region" {
  default     = null
  type        = string
  description = "S3 region. Required when TFE_OBJECT_STORAGE_TYPE is s3."
}

variable "s3_bucket" {
  default     = null
  type        = string
  description = "S3 bucket name. Required when TFE_OBJECT_STORAGE_TYPE is s3."
}

variable "s3_endpoint" {
  default     = null
  type        = string
  description = "S3 endpoint. Useful when using a private S3 endpoint. Leave blank to use the default AWS S3 endpoint. Defaults to \"\" if no value is given."
}

variable "s3_server_side_encryption" {
  default     = null
  type        = string
  description = "Server-side encryption algorithm to use. Set to aws:kms to use AWS KMS. Leave blank to disable server-side encryption. Defaults to \"\" if no value is given."
}

variable "s3_server_side_encryption_kms_key_id" {
  default     = null
  type        = string
  description = "KMS key ID to use for server-side encryption. Leave blank to use AWS-managed keys. Defaults to \"\" if no value is given."
}

variable "s3_use_instance_profile" {
  default     = null
  type        = string
  description = "Whether to use the instance profile for authentication. Defaults to false if no value is given."
}

variable "storage_type" {
  type        = string
  description = "Type of object storage to use. Must be one of s3, azure, or google. Required when TFE_OPERATIONAL_MODE is external or active-active."
  validation {
    condition     = contains(["s3", "google", "azure"], var.storage_type)
    error_message = "The storage_type value must be one of: \"s3\"; \"google\"; \"azure\"."
  }
}

variable "tfe_image" {
  type        = string
  description = "The registry path, image name, and image version (e.g. \"quay.io/hashicorp/terraform-enterprise:1234567\")"
}

variable "tfe_license" {
  type        = string
  description = "The HashiCorp license. Defaults to \"\" if no value is given. Required when TFE_LICENSE_PATH is unset."
}

variable "tls_ca_bundle_file" {
  default     = null
  type        = string
  description = "Path to a file containing TLS CA certificates to be added to the OS CA certificates bundle. Leave blank to not add CA certificates to the OS CA certificates bundle. Defaults to \"\" if no value is given."
}

variable "tls_ciphers" {
  type        = string
  description = "TLS ciphers to use for TLS. Must be valid OpenSSL format. Leave blank to use the default ciphers. Defaults to \"\" if no value is given."
}

variable "tls_version" {
  default     = null
  type        = string
  description = "(Not needed if is_replicated_deployment is true) TLS version to use. Leave blank to use both TLS v1.2 and TLS v1.3. Defaults to `\"\"` if no value is given."
  validation {
    condition = (
      var.tls_version == null ||
      var.tls_version == "tls_1_2" ||
      var.tls_version == "tls_1_3" ||
      var.tls_version == "tls_1_2_tls_1_3"
    )
    error_message = "The tls_version value must be 'tls_1_2', 'tls_1_3', or null."
  }
}

variable "trusted_proxies" {
  default     = []
  description = "A list of IP address ranges which will be considered safe to ignore when evaluating the IP addresses of requests like those made to the IACT endpoint."
  type        = list(string)
}

variable "vault_address" {
  type        = string
  description = "Address of the external Vault server (e.g. https://vault.example.com:8200). Defaults to \"\" if no value is given. Required when TFE_VAULT_USE_EXTERNAL is true."
}

variable "vault_namespace" {
  type        = string
  description = "Vault namespace. External Vault only. Leave blank to use the default namespace. Defaults to \"\" if no value is given."
}

variable "vault_path" {
  type        = string
  description = "Vault path when AppRole is mounted. External Vault only. Defaults to auth/approle if no value is given."
}

variable "vault_role_id" {
  type        = string
  description = "Vault role ID. External Vault only. Required when TFE_VAULT_USE_EXTERNAL is true."
}

variable "vault_secret_id" {
  type        = string
  description = "Vault secret ID. External Vault only. Required when TFE_VAULT_USE_EXTERNAL is true."
}

variable "vault_token_renew" {
  type        = number
  description = "Vault token renewal period in seconds. Required when TFE_VAULT_USE_EXTERNAL is true."
}

variable "enable_run_exec_tmpfs" {
  default     = false
  type        = bool
  description = "Enable the use of executables in the tmpfs for the /run directory. Defaults to false."
}
