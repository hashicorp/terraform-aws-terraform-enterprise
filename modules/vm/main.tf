# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  # Use existing security group if provided, otherwise create new one
  use_existing_security_group = var.existing_security_group_id != null
  security_group_id           = local.use_existing_security_group ? var.existing_security_group_id : aws_security_group.tfe_instance[0].id
}

###############
# TFE CLUSTER #
###############
resource "aws_security_group" "tfe_instance" {
  count  = local.use_existing_security_group ? 0 : 1
  name   = "${var.friendly_name_prefix}-tfe-ec2-sg"
  vpc_id = var.network_id
}

resource "aws_security_group_rule" "tfe_ui" {
  count = local.use_existing_security_group ? 0 : 1 # Skip rules if using existing SG

  security_group_id        = local.security_group_id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.aws_lb
  cidr_blocks              = var.aws_lb == null ? var.network_private_subnet_cidrs : null
}

resource "aws_security_group_rule" "vault_cluster" {
  count = var.active_active && !local.use_existing_security_group ? 1 : 0 # Skip if using existing SG

  security_group_id        = local.security_group_id
  type                     = "ingress"
  from_port                = 8201
  to_port                  = 8201
  protocol                 = "tcp"
  source_security_group_id = var.aws_lb
  cidr_blocks              = var.aws_lb == null ? var.network_private_subnet_cidrs : null
}

resource "aws_security_group_rule" "ssh_inbound" {
  count = var.enable_ssh && !local.use_existing_security_group ? 1 : 0 # Skip if using existing SG

  security_group_id        = local.security_group_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = var.aws_lb
  cidr_blocks              = var.aws_lb == null ? var.network_private_subnet_cidrs : null
}

resource "aws_security_group_rule" "tfe_inbound" {
  count = local.use_existing_security_group ? 0 : 1 # Skip if using existing SG

  security_group_id = local.security_group_id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
}

resource "aws_security_group_rule" "tfe_outbound" {
  count = local.use_existing_security_group ? 0 : 1 # Skip if using existing SG

  security_group_id = local.security_group_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tfe_dashboard" {
  count = (!var.active_active || var.is_replicated_deployment) && !local.use_existing_security_group ? 1 : 0 # Skip if using existing SG

  security_group_id        = local.security_group_id
  type                     = "ingress"
  from_port                = 8800
  to_port                  = 8800
  protocol                 = "tcp"
  source_security_group_id = var.aws_lb
  cidr_blocks              = var.aws_lb == null ? var.network_private_subnet_cidrs : null
}

resource "aws_security_group_rule" "tfe_admin_api" {
  count = local.use_existing_security_group ? 0 : 1 # Skip if using existing SG

  security_group_id        = local.security_group_id
  type                     = "ingress"
  from_port                = var.admin_api_https_port
  to_port                  = var.admin_api_https_port
  protocol                 = "tcp"
  source_security_group_id = var.aws_lb
  cidr_blocks              = var.aws_lb == null ? var.network_private_subnet_cidrs : null
}

resource "aws_launch_template" "tfe" {
  name_prefix            = "${var.friendly_name_prefix}-tfe-ec2-asg-launch-template-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  user_data              = var.user_data_base64
  key_name               = var.key_name
  vpc_security_group_ids = [local.security_group_id]

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

  dynamic "block_device_mappings" {
    for_each = var.enable_disk ? [1] : [0]

    content {
      device_name = var.ebs_device_name
      ebs {
        encrypted             = true
        volume_size           = var.ebs_volume_size
        volume_type           = var.ebs_volume_type
        iops                  = var.ebs_iops
        delete_on_termination = var.ebs_delete_on_termination
        snapshot_id           = var.ebs_snapshot_id
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tfe_asg" {
  name                = "${var.friendly_name_prefix}-tfe-asg"
  min_size            = var.node_count
  max_size            = var.node_count
  desired_capacity    = var.node_count
  vpc_zone_identifier = var.network_subnets_private
  target_group_arns = var.active_active || !var.is_replicated_deployment ? [
    var.aws_lb_target_group_tfe_tg_443_arn,
    var.aws_lb_target_group_tfe_tg_admin_api_arn,
    ] : [
    var.aws_lb_target_group_tfe_tg_8800_arn,
    var.aws_lb_target_group_tfe_tg_443_arn,
    var.aws_lb_target_group_tfe_tg_admin_api_arn,
  ]
  # Increases grace period for any AMI that is not the default Ubuntu
  # since RHEL has longer startup time
  health_check_grace_period = local.health_check_grace_period
  health_check_type         = var.health_check_type

  launch_template {
    id      = aws_launch_template.tfe.id
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
