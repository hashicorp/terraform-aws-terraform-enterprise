# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  redis_user_data_template = "${path.module}/files/script.sh"
  redis_user_data = templatefile(local.redis_user_data_template, {
    redis_init = base64encode(file(local.redis_init_path))
    fullchain  = var.redis_client_cert
    privkey    = var.redis_client_key
    isrgrootx1 = var.redis_client_ca
    redis_conf = base64encode(templatefile(local.redis_conf_path, {
    }))
    compose = base64encode(templatefile(local.compose_path, {
      redis_port = var.redis_port
    }))
  })
  compose_path    = "${path.module}/files/compose.yaml"
  redis_conf_path = "${path.module}/files/redis.conf"
  redis_init_path = "${path.module}/files/redis-init.sh"
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
