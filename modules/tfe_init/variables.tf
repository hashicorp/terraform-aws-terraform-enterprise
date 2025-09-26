# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "enable_redis_mtls" {
  default     = false
  type        = bool
  description = "Should Redis mTLS be enabled? This requires the redis_ca_certificate_secret_id, redis_client_key_secret_id and redis_client_certificate_secret_id variables to be set."
}

variable "enable_postgres_mtls" {
  default     = false
  type        = bool
  description = "Should postgres mTLS be enabled? This requires the postgres_ca_certificate_secret_id, postgres_client_key_secret_id and postgres_client_certificate_secret_id variables to be set."
}

variable "enable_sentinel_mtls" {
  type        = bool
  description = "Whether or not to use mutual TLS to access Redis Sentinel. Defaults to false if no value is given."
  default     = false
}

variable "ca_certificate_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded public certificate of a certificate authority (CA) to be trusted by the TFE instance(s)."
}

variable "certificate_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded public certificate for the TFE instance(s)."
}

variable "redis_ca_certificate_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded public certificate of a certificate authority (CA) to be trusted by the redis instance"
}

variable "redis_client_certificate_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded public certificate for redis instance."
}

variable "postgres_ca_certificate_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded public certificate of a certificate authority (CA) to be trusted by the database instance"
}

variable "postgres_client_certificate_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded public certificate for database instance."
}

variable "postgres_client_key_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded private key for the database instance"
}

variable "cloud" {
  default     = null
  type        = string
  description = "(Required) On which cloud is this Terraform Enterprise installation being deployed?"
  validation {
    condition     = contains(["aws", "azurerm", "google"], var.cloud)
    error_message = "Supported values for cloud are 'aws', 'azurerm', or 'google'."
  }
}

variable "container_runtime_engine" {
  default     = "docker"
  type        = string
  description = "The container runtime engine to run the FDO container on. Default is docker."
  validation {
    condition     = contains(["docker", "podman"], var.container_runtime_engine)
    error_message = "Supported values for container_runtime_enginer are docker and podman."
  }
}

variable "custom_image_tag" {
  default     = null
  type        = string
  description = "(Required if tbw_image is 'custom_image'.) The name and tag for your alternative Terraform build worker image in the format <name>:<tag>. Default is 'hashicorp/build-worker:now'. If this variable is used, the 'tbw_image' variable must be 'custom_image'."
}

variable "disk_device_name" {
  default     = null
  description = "The name of the disk device on which Terraform Enterprise will store data in Mounted Disk mode."
  type        = string
}

variable "disk_path" {
  default     = null
  description = "The pathname of the directory in which Terraform Enterprise will store data in Mounted Disk mode."
  type        = string
}

variable "distribution" {
  default     = null
  type        = string
  description = "(Required) What is the OS distribution of the instance on which Terraoform Enterprise will be deployed?"
  validation {
    condition     = contains(["rhel", "ubuntu"], var.distribution)
    error_message = "Supported values for distribution are 'rhel', or 'ubuntu'."
  }
}

variable "docker_compose_yaml" {
  default     = null
  description = "The yaml encoded contents of what make up a docker compose file, to be run with docker compose in the user data script"
}

variable "docker_version_rhel" {
  default     = "24.0.2"
  description = "When you run `yum list docker-ce --showduplicates | sort -r`, the version comes from the center column. All you need is the format major.minor.patch format."
}

variable "enable_monitoring" {
  default     = null
  type        = bool
  description = "Should cloud appropriate monitoring agents be installed as a part of the TFE installation script?"
}

variable "extra_no_proxy" {
  default     = null
  type        = list(string)
  description = "When configured to use a proxy, a list of hosts to exclude from proxying. Please note that this list does not support whitespace characters."
}

variable "key_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded private key for the TFE instance(s)."
}

variable "operational_mode" {
  default     = null
  description = "A special string to control the operational mode of Terraform Enterprise. Valid values are: 'external' for External Services mode; 'disk' for Mounted Disk mode; 'active-active' for Active/Active mode."
}

variable "podman_kube_yaml" {
  default     = null
  description = "The yaml encoded contents of what makes up a podman kube yaml file, to be run with podman play kube in the user data script"
}

variable "proxy_ip" {
  default     = null
  type        = string
  description = "IP Address of the proxy server"
}

variable "proxy_port" {
  default     = null
  type        = string
  description = "Port that the proxy server will use"
}

variable "redis_client_key_secret_id" {
  default     = null
  type        = string
  description = "A secret ID which contains the Base64 encoded version of a PEM encoded private key for the redis instance"
}

variable "registry" {
  default     = null
  type        = string
  description = "The docker registry from which to source the terraform_enterprise container images."
}

variable "registry_password" {
  default     = null
  description = "The password for the docker registry from which to pull the terraform_enterprise container images."
  type        = string
}

variable "registry_username" {
  default     = null
  description = "The username for the docker registry from which to pull the terraform_enterprise container images."
  type        = string
}

variable "tfe_image" {
  type        = string
  description = "The registry path, image name, and image version (e.g. \"quay.io/hashicorp/terraform-enterprise:1234567\")"
}

### Database details
variable "database_host" {
  default     = null
  type        = string
  description = "The PostgreSQL server to connect to. Required when Azure PostgreSQL MSI auth is enabled"
}

variable "database_name" {
  default     = null
  type        = string
  description = "Name of the PostgreSQL database to store application data in."
}

variable "admin_database_username" {
  default     = null
  type        = string
  description = "PostgreSQL user."
}

variable "admin_database_password" {
  default     = null
  type        = string
  description = "PostgreSQL password."
}

variable "database_passwordless_azure_use_msi" {
  default     = false
  type        = bool
  description = "Whether or not to use Azure Managed Service Identity (MSI) to connect to the PostgreSQL database. Defaults to false if no value is given."
}
