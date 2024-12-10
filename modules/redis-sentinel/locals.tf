# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  redis_user_data_template = "${path.module}/script.sh"
  redis_leader_user_data          = templatefile(local.redis_user_data_template, {

    compose = base64encode(templatefile(local.compose_path, {
      redis_sentinel_password = var.redis_sentinel_password  
      redis_sentinel_leader_name = var.redis_sentinel_leader_name
      redis_sentinel_port = var.redis_sentinel_port
      redis_port = var.redis_port
      redis_password = var.redis_password
    }))}) 
  compose_path = "${path.module}/compose.yaml"
  tags = concat(
    [
      {
        key                 = "Name"
        value               = "${var.friendly_name_prefix}-tfe"
        propagate_at_launch = true
      },
    ],
    [
      for k, v in var.asg_tags : {
        key                 = k
        value               = v
        propagate_at_launch = true
      }
    ]
  )
  default_health_check_grace_period = 1500
  health_check_grace_period         = var.health_check_grace_period != null ? var.health_check_grace_period : local.default_health_check_grace_period
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}