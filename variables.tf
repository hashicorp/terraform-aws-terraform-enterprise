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

variable "distribution" {
  type        = string
  description = "(Required) What is the OS distribution of the instance on which Terraoform Enterprise will be deployed?"
  validation {
    condition     = contains(["rhel", "ubuntu"], var.distribution)
    error_message = "Supported values for distribution are 'rhel' or 'ubuntu'."
  }
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

variable "object_storage_iam_user" {
  default     = null
  description = <<-EOD
  The IAM user that will be authorized to access the S3 storage bucket which holds Terraform Enterprise runtime data.
  This value requires var.aws_access_key_id and var.aws_secret_access_key to also be set. The values of those variables
  must represent an access key that is associated with this user.
  EOD
  type        = object({ arn = string })
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
  default     = "5.0.6"
  description = "Redis enginer version."
}

variable "redis_parameter_group_name" {
  type        = string
  default     = "default.redis5.0"
  description = "Redis parameter group name."
}

variable "redis_use_password_auth" {
  type        = bool
  description = "Determine if a password is required for Redis."
  default     = false
}

# Postgres
# --------
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

variable "db_size" {
  type        = string
  default     = "db.m4.xlarge"
  description = "PostgreSQL instance size."
}

variable "postgres_engine_version" {
  type        = string
  default     = "12.8"
  description = "PostgreSQL version."
}

# Userdata
# --------
variable "bypass_preflight_checks" {
  default     = false
  type        = bool
  description = "Allow the TFE application to start without preflight checks."
}

variable "custom_image_tag" {
  default     = null
  type        = string
  description = <<-EOD
  (Required if tbw_image is 'custom_image'.) The name and tag for your alternative Terraform
  build worker image in the format <name>:<tag>. Default is 'hashicorp/build-worker:now'.
  If this variable is used, the 'tbw_image' variable must be 'custom_image'.
  EOD
}

variable "disk_path" {
  default     = null
  description = "The pathname of the directory in which Terraform Enterprise will store data on the compute instances."
  type        = string
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
  default     = null
  type        = bool
  description = <<-EOD
  (Optional) Metrics are used to understand the behavior of Terraform Enterprise and to
  troubleshoot and tune performance. Enable an endpoint to expose container metrics.
  Defaults to false.
  EOD
}

variable "metrics_endpoint_port_http" {
  default     = null
  type        = number
  description = <<-EOD
  (Optional when metrics_endpoint_enabled is true.) Defines the TCP port on which HTTP metrics
  requests will be handled.
  Defaults to 9090.
  EOD
}

variable "metrics_endpoint_port_https" {
  default     = null
  type        = string
  description = <<-EOD
  (Optional when metrics_endpoint_enabled is true.) Defines the TCP port on which HTTPS metrics
  requests will be handled.
  Defaults to 9091.
  EOD
}

variable "operational_mode" {
  default     = "external"
  description = <<-EOD
  A special string to control the operational mode of Terraform Enterprise. Valid values are: "external" for External
  Services mode; "disk" for Mounted Disk mode.
  EOD
  type        = string

  validation {
    condition     = contains(["external", "disk"], var.operational_mode)
    error_message = "The operational_mode value must be one of: \"external\"; \"disk\"."
  }
}

variable "tbw_image" {
  default     = null
  type        = string
  description = <<-EOD
  Set this to 'custom_image' if you want to use an alternative Terraform build worker image,
  and use the 'custom_image_tag' variable to define its name and tag.
  Default is 'default_image'. 
  EOD

  validation {
    condition = (
      var.tbw_image == "default_image" ||
      var.tbw_image == "custom_image" ||
      var.tbw_image == null
    )
    error_message = "The tbw_image must be 'default_image', 'custom_image', or null. If left unset, TFE will default to 'default_image'."
  }
}

variable "tfe_license_file_location" {
  default     = "/etc/terraform-enterprise.rli"
  type        = string
  description = "The path on the TFE instance to put the TFE license."
}

variable "tls_bootstrap_cert_pathname" {
  default     = null
  type        = string
  description = "The path on the TFE instance to put the certificate. ex. '/var/lib/terraform-enterprise/certificate.pem'"
}

variable "tls_bootstrap_key_pathname" {
  default     = null
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
  description = <<-EOF
  Parameter keywords of the form param1=value1&param2=value2 to support additional options that
  may be necessary for your specific PostgreSQL server. Allowed values are documented on the
  PostgreSQL site. An additional restriction on the sslmode parameter is that only the require,
  verify-full, verify-ca, and disable values are allowed.
  EOF
}

variable "release_sequence" {
  default     = null
  type        = number
  description = "Terraform Enterprise release sequence"
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

# KMS & Secrets Manager
# ---------------------
variable "ca_certificate_secret_id" {
  default     = null
  type        = string
  description = <<-EOD
  A Secrets Manager secret ARN to the secret which contains the Base64 encoded version of
  a PEM encoded public certificate of a certificate authority (CA) to be trusted by the EC2
  instance(s). This argument is only required if TLS certificates in the deployment are not
  issued by a well-known CA.
  EOD
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
  description = <<-EOD
  A list of IP address ranges which will be considered safe to ignore when evaluating the IP addresses of requests like
  those made to the IACT endpoint.
  EOD
  type        = list(string)
}

# Air-gapped Installations ONLY
# -----------------------------
variable "airgap_url" {
  default     = null
  type        = string
  description = <<-EOD
  The URL of the storage bucket object that comprises an airgap package. This is only used in development
  environments when bootstapping the TFE instance with the airgap package. You would not use this for an
  actual airgapped environment.
  EOD
}

variable "tfe_license_bootstrap_airgap_package_path" {
  default     = null
  type        = string
  description = <<-EOD
  (Required if air-gapped installation) The URL of a Replicated airgap package for Terraform
  Enterprise. The suggested path is "/var/lib/ptfe/ptfe.airgap".
  EOD
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
  description = <<-EOD
  (Required if Mounted Disk installation) The device name that AWS renames the ebs_device_name to.
  See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html for more details.
  EOD
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