# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  redis_username           = try(random_pet.redis_username[0].id, null)
  redis_password           = try(random_password.redis_password[0].result, null)
  sentinel_username        = try(random_pet.sentinel_username[0].id, null)
  sentinel_password        = try(random_password.sentinel_password[0].result, null)
  redis_user_data_template = "${path.module}/files/script.sh"
  redis_leader_user_data = templatefile(local.redis_user_data_template, {
    redis_init = base64encode(file(local.redis_init_path))
    redis_conf = base64encode(templatefile(local.redis_conf_path, {
      redis_username = local.redis_username
      redis_password = local.redis_password
    }))
    compose = var.enable_sentinel_mtls ? base64encode(templatefile(local.compose_path, {
      redis_sentinel_port = var.redis_sentinel_port
      redis_port          = var.redis_port
      redis_client_cert = var.redis_client_certificate_secret_id
      redis_client_key  = var.redis_client_key_secret_id
      redis_client_ca   = var.redis_ca_certificate_secret_id
      })) : base64encode(templatefile(local.compose_path, {
      redis_password      = local.redis_password
      redis_sentinel_port = var.redis_sentinel_port
      redis_port          = var.redis_port
    }))
    sentinel_start_script = var.enable_sentinel_mtls ? base64encode(templatefile(local.sentinel_start_script_tls_path, {
      redis_sentinel_leader_name = var.redis_sentinel_leader_name
      redis_sentinel_port        = var.redis_sentinel_port
      redis_port                 = var.redis_port
      redis_client_cert = var.redis_client_certificate_secret_id
      redis_client_key  = var.redis_client_key_secret_id
      redis_client_ca   = var.redis_ca_certificate_secret_id
      })) : base64encode(templatefile(local.sentinel_start_script_path, {
      redis_sentinel_password    = local.sentinel_password
      redis_sentinel_username    = local.sentinel_username
      redis_sentinel_leader_name = var.redis_sentinel_leader_name
      redis_sentinel_port        = var.redis_sentinel_port
      redis_port                 = var.redis_port
      redis_password             = local.redis_password
      redis_username             = local.redis_username
    }))
  })
  sentinel_start_script_tls_path = "${path.module}/files/sentinel_start_tls.sh"
  sentinel_start_script_path     = "${path.module}/files/sentinel_start.sh"
  compose_path                   = "${path.module}/files/compose.yaml"
  redis_conf_path                = "${path.module}/files/redis.conf"
  redis_init_path                = "${path.module}/files/redis-init.sh"
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
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
