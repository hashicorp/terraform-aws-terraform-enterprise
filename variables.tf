# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Common
# ------
variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN to use with load balancer"
}

variable "ami_id" {
  type        = string
  default     = null
  description = "AMI ID to use for TFE instances"
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

variable "ec2_launch_template_tag_specifications" {
  description = "(Optional) List of tag specifications to apply to the launch template."
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))
  default = []
}

variable "asg_tags" {
  type        = map(string)
  description = "(Optional) Map of tags only used for the autoscaling group. If you are using the AWS provider's default_tags,please note that it tags every taggable resource except for the autoscaling group, therefore this variable may be used to duplicate the key/value pairs in the default_tags if you wish."
  default     = {}
}

variable "aws_access_key_id" {
  default     = null
  description = "The identity of the access key which TFE will use to authenticate with S3. This value requires var. aws_secret_access_key and var.object_storage_iam_user to also be set."
  type        = string
}

variable "aws_secret_access_key" {
  default     = null
  description = "The secret access key which TFE will use to authenticate with S3. This value requires var.aws_secret_access_key and var.object_storage_iam_user to also be set."
  type        = string
}

variable "distribution" {
  type        = string
  description = "(Required) What is the OS distribution of the instance on which Terraoform Enterprise will be deployed?"
  validation {
    condition     = contains(["rhel", "ubuntu", "amazon-linux-2023"], var.distribution)
    error_message = "Supported values for distribution are 'rhel', 'ubuntu' or amazon-linux-2023."
  }
}

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "enable_monitoring" {
  default     = null
  type        = bool
  description = "Should cloud appropriate monitoring agents be installed as a part of the TFE installation script?"
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

variable "object_storage_iam_user" {
  default     = null
  description = "The IAM user that will be authorized to access the S3 storage bucket which holds Terraform Enterprise runtime data. This value requires var.aws_access_key_id and var.aws_secret_access_key to also be set. The values of those variables must represent an access key that is associated with this user."
  type        = object({ arn = string })
}

variable "s3_endpoint" {
  default     = null
  description = "S3 endpoint. Useful when using a private S3 endpoint. Leave blank to use the default AWS S3 endpoint. Defaults to \"\"."
  type        = string
}


variable "vm_certificate_secret_id" {
  default     = null
  type        = string
  description = "A Secrets Manager secret ARN which contains the Base64 encoded version of a PEM encoded public certificate for the Virtual Machine Scale Set."
}

variable "vm_key_secret_id" {
  default     = null
  type        = string
  description = "A Secrets Manager secret ARN which contains the Base64 encoded version of a PEM encoded private key for the Virtual Machine Scale Set."
}

# Redis
# -----
variable "redis_cache_size" {
  type        = string
  default     = "cache.m4.large"
  description = "Redis instance size."
}

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

variable "redis_engine_version" {
  type        = string
  default     = "7.0"
  description = "Redis engine version."
}

variable "redis_parameter_group_name" {
  type        = string
  default     = "default.redis7"
  description = "Redis parameter group name."
}

variable "redis_use_password_auth" {
  type        = bool
  description = "Determine if a password is required for Redis."
  default     = false
}

# Postgres
# --------
variable "db_name" {
  default     = "hashicorp"
  type        = string
  description = "PostgreSQL instance name."
}

variable "db_username" {
  default     = "hashicorp"
  type        = string
  description = "PostgreSQL instance username. No special characters."
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

variable "db_parameters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection."
  default     = "sslmode=require"
}

variable "db_size" {
  type        = string
  default     = "db.m5.xlarge"
  description = "PostgreSQL instance size."
}

variable "postgres_engine_version" {
  type        = string
  default     = "12.15"
  description = "PostgreSQL version."
}

# Userdata
# --------
variable "bypass_preflight_checks" {
  default     = false
  type        = bool
  description = "Allow the TFE application to start without preflight checks."
}

variable "capacity_cpu" {
  default     = 0
  description = "Maximum number of CPU cores a Terraform run is allowed to use. Set to `0` for no limit. Defaults to `0` if no value is given."
  type        = number
}

variable "capacity_concurrency" {
  default     = 10
  description = "The maximum number of Terraform runs that will be executed concurrently on each compute instance. Defaults to `10` if no value is given."
  type        = number
}

variable "capacity_memory" {
  default     = 2048
  type        = number
  description = "The maximum amount of memory (in megabytes) that a Terraform plan or apply can use on the system; defaults to `512` for replicated mode and `2048` for FDO."
}

variable "custom_agent_image_tag" {
  default     = null
  type        = string
  description = "Configure the docker image for handling job execution within TFE. This can either be the standard image that ships with TFE or a custom image that includes extra tools not present in the default one."
}

variable "custom_image_tag" {
  default     = null
  type        = string
  description = "The name and tag for your alternative Terraform build worker image in the format <name>:<tag>. Default is 'hashicorp/build-worker:now'."
}

variable "disk_path" {
  default     = null
  description = "The pathname of the directory in which Terraform Enterprise will store data on the compute instances. Required if var.is_replicated_deployment is false and var.operational_mode is 'disk'."
  type        = string
}

variable "hairpin_addressing" {
  default     = null
  type        = bool
  description = "In some cloud environments, HTTP clients running on instances behind a loadbalancer cannot send requests to the public hostname of that load balancer. Use this setting to configure TFE services to redirect requests for the installation's FQDN to the instance's internal IP address. Defaults to false."
}

variable "http_port" {
  default     = 8080
  type        = number
  description = "(Optional if is_replicated_deployment is false) Port application listens on for HTTP. Default is 80."
}

variable "https_port" {
  default     = 8443
  type        = number
  description = "(Optional if is_replicated_deployment is false) Port application listens on for HTTPS. Default is 443."
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

variable "operational_mode" {
  default     = "external"
  description = "A special string to control the operational mode of Terraform Enterprise. Valid values are: 'external' for External Services mode; 'disk for Mounted Disk mode."
  type        = string

  validation {
    condition     = contains(["external", "disk"], var.operational_mode)
    error_message = "The operational_mode value must be one of: \"external\"; \"disk\"."
  }
}

variable "tfe_license_file_location" {
  default     = "/etc/terraform-enterprise.rli"
  type        = string
  description = "The path on the TFE instance to put the TFE license."
}

variable "tls_bootstrap_cert_pathname" {
  default     = "/var/lib/terraform-enterprise/certificate.pem"
  type        = string
  description = "The path on the TFE instance to put the certificate. ex. '/var/lib/terraform-enterprise/certificate.pem'"
}

variable "tls_bootstrap_key_pathname" {
  default     = "/var/lib/terraform-enterprise/key.pem"
  type        = string
  description = "The path on the TFE instance to put the key. ex. '/var/lib/terraform-enterprise/key.pem'"
}

# Network
# -------
variable "admin_dashboard_ingress_ranges" {
  type        = list(string)
  description = "(Optional) List of CIDR ranges that are allowed to acces the admin dashboard. Only used for standalone installations."
  default     = ["0.0.0.0/0"]
}

variable "deploy_vpc" {
  type        = bool
  description = "(Optional) Boolean indicating whether to deploy a VPC (true) or not (false)."
  default     = true
}

variable "enable_ssh" {
  type        = bool
  description = "Whether to open port 22 on the TFE instance for SSH access."
  default     = false
}

variable "hc_license" {
  default     = null
  type        = string
  description = "(Not needed if is_replicated_deployment is true) The raw TFE license that is validated on application startup."
}

variable "is_replicated_deployment" {
  type        = bool
  description = "TFE will be installed using a Replicated license and deployment method."
  default     = true
}

variable "network_cidr" {
  type        = string
  description = "(Optional) CIDR block for VPC."
  default     = "10.0.0.0/16"
}

variable "network_id" {
  default     = null
  description = "The identity of the VPC in which resources will be deployed."
  type        = string
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
  default     = ["10.0.32.0/20", "10.0.48.0/20"]
}

variable "network_private_subnets" {
  default     = []
  description = "A list of the identities of the private subnetworks in which resources will be deployed."
  type        = list(string)
}


variable "network_public_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of public subnet CIDR ranges to create in VPC."
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}


variable "network_public_subnets" {
  default     = []
  description = "A list of the identities of the public subnetworks in which resources will be deployed."
  type        = list(string)
}

# TFE Instance(s)
# ---------------
variable "existing_iam_instance_profile_name" {
  default     = null
  description = "The IAM instance profile to be attached to the TFE EC2 instance(s). Leave the value null to create a new one."
  type        = string
}

variable "existing_iam_instance_role_name" {
  default     = null
  description = "The IAM role to associate with the instance profile. Leave the value null to create a new one."
  type        = string
}

variable "health_check_grace_period" {
  default     = null
  description = "The health grace period aws provides to allow for an instance to pass it's health check."
  type        = number
}

variable "health_check_type" {
  description = "Type of health check to perform on the instance."
  type        = string
  default     = "ELB"

  validation {
    condition     = contains(["ELB", "EC2"], var.health_check_type)
    error_message = "Must be one of [ELB, EC2]."
  }
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

variable "license_reporting_opt_out" {
  default     = false
  type        = bool
  description = "(Not needed if is_replicated_deployment is true) Whether to opt out of reporting licensing information to HashiCorp. Defaults to false."
}

variable "node_count" {
  type        = number
  default     = 2
  description = "The number of nodes you want in your autoscaling group (1 for standalone, 2 for active-active configuration)"

  validation {
    condition     = var.node_count <= 5
    error_message = "The node_count value must be less than or equal to 5."
  }
}

variable "pg_extra_params" {
  default     = null
  type        = string
  description = "Parameter keywords of the form param1=value1&param2=value2 to support additional options that may be necessary for your specific PostgreSQL server. Allowed values are documented on the PostgreSQL site. An additional restriction on the sslmode parameter is that only the require, verify-full, verify-ca, and disable values are allowed."
}

variable "registry" {
  default     = "images.releases.hashicorp.com"
  type        = string
  description = "(Not needed if is_replicated_deployment is true) The docker registry from which to source the terraform_enterprise container images."
}

variable "registry_password" {
  default     = null
  type        = string
  description = "(Not needed if is_replicated_deployment is true) The password for the docker registry from which to source the terraform_enterprise container images."
}

variable "registry_username" {
  default     = null
  type        = string
  description = "(Not needed if is_replicated_deployment is true) The username for the docker registry from which to source the terraform_enterprise container images."
}

variable "release_sequence" {
  default     = null
  type        = number
  description = "Terraform Enterprise release sequence"
}

variable "run_pipeline_image" {
  default     = null
  type        = string
  description = "(Not needed if is_replicated_deployment is true) Container image used to execute Terraform runs. Leave blank to use the default image that comes with Terraform Enterprise. Defaults to ''."
}

variable "ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
  description = "SSL policy to use on ALB listener"
}

variable "tfe_image" {
  default     = "images.releases.hashicorp.com/hashicorp/terraform-enterprise:v202311-1"
  type        = string
  description = "(Not needed if is_replicated_deployment is true) The registry path, image name, and image version."
}

variable "tfe_subdomain" {
  type        = string
  default     = "tfe"
  description = "Subdomain for accessing the Terraform Enterprise UI."
}

variable "tls_ciphers" {
  default     = null
  type        = string
  description = "(Not needed if is_replicated_deployment is true) TLS ciphers to use for TLS. Must be valid OpenSSL format. Leave blank to use the default ciphers. Defaults to ''"
}

variable "tls_version" {
  default     = "tls_1_2_tls_1_3"
  type        = string
  description = "(Not needed if is_replicated_deployment is true) TLS version to use. Leave blank to use both TLS v1.2 and TLS v1.3. Defaults to '' if no value is given."
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

# KMS & Secrets Manager
# ---------------------
variable "ca_certificate_secret_id" {
  default     = null
  type        = string
  description = "A Secrets Manager secret ARN to the secret which contains the Base64 encoded version of a PEM encoded public certificate of a certificate authority (CA) to be trusted by the EC2 instance(s). This argument is only required if TLS certificates in the deployment are not issued by a well-known CA."
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key arn for AWS KMS Customer managed key."
}

variable "tfe_license_secret_id" {
  type        = string
  description = "The Secrets Manager secret ARN under which the Base64 encoded Terraform Enterprise license is stored."
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

# Proxy Settings
# --------------
variable "no_proxy" {
  type        = list(string)
  description = "(Optional) List of IP addresses to not proxy"
  default     = []
}

variable "proxy_ip" {
  type        = string
  description = "(Optional) IP address of existing web proxy to route TFE traffic through."
  default     = null
}

variable "proxy_port" {
  default     = null
  type        = string
  description = "Port that the proxy server will use"
}

variable "trusted_proxies" {
  default     = []
  description = "A list of IP address ranges which will be considered safe to ignore when evaluating the IP addresses of requests like those made to the IACT endpoint."
  type        = list(string)
}

# Air-gapped Installations ONLY
# -----------------------------
variable "airgap_url" {
  default     = null
  type        = string
  description = "The URL of the storage bucket object that comprises an airgap package. This is only used in development environments when bootstapping the TFE instance with the airgap package. You would not use this for an actual airgapped environment."
}

variable "tfe_license_bootstrap_airgap_package_path" {
  default     = null
  type        = string
  description = "(Required if air-gapped installation) The URL of a Replicated airgap package for Terraform Enterprise. The suggested path is '/var/lib/ptfe/ptfe.airgap'."
}

# Mounted Disk Installations ONLY
# -------------------------------
variable "ebs_delete_on_termination" {
  type        = bool
  default     = true
  description = "(Optional if Mounted Disk installation) Whether the volume should be destroyed on instance termination."
}

variable "ebs_device_name" {
  type        = string
  default     = "xvdcc"
  description = "(Required if Mounted Disk installation) The name of the device to mount."
}

variable "ebs_iops" {
  type        = number
  default     = 3000
  description = "(Optional if Mounted Disk installation) The amount of provisioned IOPS. This must be set with a volume_type of 'io1'."
}

variable "ebs_renamed_device_name" {
  type        = string
  default     = "nvme1n1"
  description = "(Required if Mounted Disk installation) The device name that AWS renames the ebs_device_name to. See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html for more details."
}

variable "ebs_volume_size" {
  type        = number
  default     = 200
  description = "(Optional if Mounted Disk installation) The size of the volume in gigabytes."
}

variable "ebs_volume_type" {
  type        = string
  default     = "io1"
  description = "(Optional if Mounted Disk installation) The type of volume."

  validation {
    condition     = contains(["standard", "gp2", "gp3", "st1", "sc1", "io1"], var.ebs_volume_type)
    error_message = "The ebs_volume_type value must be one of: 'standard', 'gp2', 'gp3', 'st1', 'sc1', 'io1'."
  }
}

variable "ebs_snapshot_id" {
  type        = string
  description = "(Optional) The Snapshot ID to mount (instead of a new volume)"
  default     = null
}

# External Vault ONLY
# -------------------
variable "extern_vault_addr" {
  default     = null
  type        = string
  description = "(Required if var.extern_vault_enable = true) URL of external Vault cluster."
}

variable "extern_vault_enable" {
  default     = false
  type        = bool
  description = "(Optional) Indicate if an external Vault cluster is being used. Set to 1 if so."
}

variable "extern_vault_namespace" {
  default     = null
  type        = string
  description = "(Optional if var.extern_vault_enable = true) The Vault namespace"
}

variable "extern_vault_path" {
  default     = "auth/approle"
  type        = string
  description = "(Optional if var.extern_vault_enable = true) Path on the Vault server for the AppRole auth. Defaults to auth/approle."
}

variable "extern_vault_role_id" {
  default     = null
  type        = string
  description = "(Required if var.extern_vault_enable = true) AppRole RoleId to use to authenticate with the Vault cluster."
}

variable "extern_vault_secret_id" {
  default     = null
  type        = string
  description = "(Required if var.extern_vault_enable = true) AppRole SecretId to use to authenticate with the Vault cluster."
}


variable "extern_vault_token_renew" {
  default     = 3600
  type        = number
  description = "(Optional if var.extern_vault_enable = true) How often (in seconds) to renew the Vault token."
}
