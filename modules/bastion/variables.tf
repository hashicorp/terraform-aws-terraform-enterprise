variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "kms_key_id" {
  description = <<-EOD
  The Amazon Resource Name of the KMS key which will be used to encrypt the root block device of the bastion EC2 
  instance.
  EOD
  type        = string
}

variable "user_data_base64" {
  description = "A Base64 encoded user data script to be executed when the bastion EC2 instance is launched."
  type        = string
}

variable "network_id" {
  description = <<-EOD
  The identity of the VPC in which the security group attached to the bastion EC2 instance will be deployed.
  EOD
  type        = string
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "AMI ID to use for TFE instances and bastion host"
}

variable "bastion_host_subnet" {
  description = "The identity of the subnetwork in which the bastion EC2 instance will be deployed."
  type        = string
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

# Network
variable "deploy_vpc" {
  type        = bool
  description = "(Optional) Boolean indicating whether to deploy a VPC (true) or not (false)."
  default     = true
}

# Bastion
variable "deploy_bastion" {
  type        = bool
  description = "(Optional) Boolean indicating whether to deploy a Bastion instance (true) or not (false). Only specify true if deploy_vpc is true."
  default     = true
}

variable "bastion_keypair" {
  type        = string
  description = "(Optional) Specifies existing SSH key pair to use for Bastion instance. Only specify if deploy_bastion is true."
  default     = null
}

variable "bastion_ingress_cidr_allow" {
  type        = list(string)
  description = "(Optional) List of CIDR ranges to allow SSH ingress to Bastion instance. Only specify if deploy_bastion is true."
  default     = ["0.0.0.0/0"]
}
