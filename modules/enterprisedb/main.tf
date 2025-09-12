# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

###############
# ENTERPRISEDB CLUSTER #
###############
resource "aws_security_group" "enterprisedb_instance" {
  name   = "${var.friendly_name_prefix}-edb-ec2-sg"
  vpc_id = var.network_id
}

resource "aws_security_group_rule" "enterprisedb_ui" {
  security_group_id        = aws_security_group.enterprisedb_instance.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = null
  cidr_blocks              = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "ssh_inbound" {
  count = var.enable_ssh ? 1 : 0

  security_group_id        = aws_security_group.enterprisedb_instance.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = null
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_inbound" {

  security_group_id        = aws_security_group.enterprisedb_instance.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = null
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "postgres_inbound" {

  security_group_id        = aws_security_group.enterprisedb_instance.id
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "-1"
  source_security_group_id = null
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "enterprisedb_inbound" {
  security_group_id = aws_security_group.enterprisedb_instance.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
}

resource "aws_security_group_rule" "enterprisedb_outbound" {
  security_group_id = aws_security_group.enterprisedb_instance.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_launch_template" "enterprisedb" {
  name_prefix            = "${var.friendly_name_prefix}-edb-ec2-asg-launch-template-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  user_data              = base64encode(local.tfe_user_data)
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.enterprisedb_instance.id]

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

 resource "aws_instance" "edb_server" {
  ami           = "ami-06ea12056fee6f52f"
  instance_type = "m5.xlarge"
  subnet_id = var.network_subnets_private[0]
  launch_template {
    id      = aws_launch_template.enterprisedb.id
    version = "$Latest"

  }
  vpc_security_group_ids = [aws_security_group.enterprisedb_instance.id]
  tags = { for item in local.tags :
    keys(item)[0] => values(item)[0]
  }
  lifecycle {
    create_before_destroy = true
  }
}
