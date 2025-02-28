# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# Launch Template for Redis Sentinel
# ----------------------------------

resource "aws_launch_template" "redis_sentinel_leader" {
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

  # Increases grace period for any AMI that is not the default Ubuntu
  # since RHEL has longer startup time
  health_check_grace_period = local.health_check_grace_period
  health_check_type         = var.health_check_type

  launch_template {
    id      = aws_launch_template.redis_sentinel_leader.id
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
