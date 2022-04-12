variable "default_ami_id" {
  description = "The identity of the AMI which will be used to provision the TFE EC2 instance(s)."
  type        = string
}

variable "user_data_base64" {
  description = "A Base64 encoded user data script to be executed when launching the TFE EC2 instance(s)."
  type        = string
}

variable "aws_lb" {
  description = <<-EOD
  The identity of the security group attached to the load balancer which will be
  authorized to communicate with the TFE EC2 instance(s).
  EOD
  type        = string
}

variable "aws_lb_target_group_tfe_tg_443_arn" {
  description = <<-EOD
  The Amazon Resource Name of the load balancer target group for traffic on port
  443 which will be backed by the TFE EC2 autoscaling group.
  EOD
  type        = string
}

variable "aws_lb_target_group_tfe_tg_8800_arn" {
  description = <<-EOD
  The Amazon Resource Name of the load balancer target group for traffic on port
  8800 which will be backed by the TFE EC2 autoscaling group.
  EOD
  type        = string
}

variable "aws_iam_instance_profile" {
  description = "The name of the IAM instance profile to be associated with the TFE EC2 instance(s)."
  type        = string
}

variable "network_id" {
  description = "The identity of the VPC in which the security group attached to the TFE EC2 instance will be delpoyed."
  type        = string
}

variable "network_subnets_private" {
  description = <<-EOD
  A list of the identities of the private subnetworks in which the EC2 autoscaling group will be deployed.
  EOD
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type of TFE EC2 instance(s) to create."
  type        = string
}

variable "active_active" {
  type        = bool
  description = "Flag for active-active configuation: true for active-active, false for standalone"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for TFE instances"
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "node_count" {
  type        = number
  description = "The number of nodes you want in your autoscaling group (1 for standalone, 2 for active-active configuration)"
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

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
}

variable "key_name" {
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

# Mounted Disk Installation
# -------------------------
variable "ebs_device_name" {
  type        = string
  description = "(Required if Mounted Disk installation) The name of the device to mount."
}

variable "ebs_volume_size" {
  type        = number
  description = "(Optional if Mounted Disk installation) The size of the volume in gigabytes."
}

variable "ebs_volume_type" {
  type        = string
  description = "(Optional if Mounted Disk installation) (Optional) The type of volume. Can be 'standard', 'gp2', 'gp3', 'st1', 'sc1' or 'io1'. "
}

variable "ebs_iops" {
  type        = number
  description = "(Optional) The amount of provisioned IOPS. This must be set with a volume_type of 'io1'."
}

variable "ebs_delete_on_termination" {
  type        = bool
  description = "(Optional if Mounted Disk installation) Whether the volume should be destroyed on instance termination."
}

variable "enable_disk" {
  type        = bool
  description = "Will you be attaching an EBS block device for a Mounted Disk Installation?"
}