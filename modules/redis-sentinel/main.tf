# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# Launch Template for Redis Sentinel
# ----------------------------------

resource "random_password" "redis_password" {
  count            = contains(["USER_AND_PASSWORD", "PASSWORD"], var.redis_authentication_mode) ? 1 : 0
  length           = 16
  special          = true
  override_special = "#$%&*()-_=+[]{}<>:?"
}

resource "random_pet" "redis_username" {
  count = var.redis_authentication_mode == "USER_AND_PASSWORD" ? 1 : 0
}

resource "random_password" "sentinel_password" {
  count            = contains(["USER_AND_PASSWORD", "PASSWORD"], var.sentinel_authentication_mode) ? 1 : 0
  length           = 16
  special          = true
  override_special = "#$%&*()-_=+[]{}<>:?"
}

resource "random_pet" "sentinel_username" {
  count = var.sentinel_authentication_mode == "USER_AND_PASSWORD" ? 1 : 0
}


resource "aws_launch_template" "sentinel_leader" {
  name_prefix            = "${var.friendly_name_prefix}-redis-sentinel-leader"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  user_data              = base64encode(local.redis_leader_user_data)
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.redis_sentinel_inbound_allow.id, aws_security_group.redis_sentinel_outbound_allow.id]

  dynamic "tag_specifications" {
    for_each = var.ec2_launch_template_tag_specifications

    content {
      resource_type = tag_specifications.value["resource_type"]
      tags          = tag_specifications.value["tags"]
    }
  }

  iam_instance_profile {
    name = var.aws_iam_instance_profile
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted             = true
      volume_type           = "gp2"
      volume_size           = 50
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling Group for Redis Sentinel
# ------------------------------------

resource "aws_autoscaling_group" "redis_sentinel" {
  name                = "${var.friendly_name_prefix}-redis-sentinel-leader-asg"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.network_subnets_private
  target_group_arns = concat(
    [for tg in aws_lb_target_group.redis_sentinel_tg : tg.arn],
    [for tg in aws_lb_target_group.redis_sentinel_tg_redis : tg.arn]
  )

  # Increases grace period for any AMI that is not the default Ubuntu
  # since RHEL has longer startup time
  health_check_grace_period = local.health_check_grace_period
  health_check_type         = var.health_check_type

  launch_template {
    id      = aws_launch_template.sentinel_leader.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Data source to get instances from the Auto Scaling Group
# -------------------------------------------------------

data "aws_instances" "redis_sentinel" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.redis_sentinel.name]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [aws_autoscaling_group.redis_sentinel]
}

# Data source to get detailed instance information including public IPs
# --------------------------------------------------------------------

data "aws_instance" "redis_sentinel" {
  count       = length(data.aws_instances.redis_sentinel.ids)
  instance_id = data.aws_instances.redis_sentinel.ids[count.index]
}

resource "aws_eip" "redis_eip" {
  vpc = true
}

resource "aws_eip_association" "redis_eip_assoc" {
  count        = length(data.aws_instance.redis_sentinel)
  instance_id  = aws_instance.redis_sentinel[count.index].id
  allocation_id = aws_eip.redis_eip.id
}

resource "aws_route53_record" "sentinel" {
  zone_id = data.aws_route53_zone.tfe.zone_id
  name    = "${var.friendly_name_prefix}-redis-sentinel"
  type    = "A"
  ttl     = 300
  records = [aws_eip.redis_eip.public_ip]
}