# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Allow inbound from Redis instances to TFE VPC

resource "aws_security_group" "redis_inbound_allow" {
  name   = "${var.friendly_name_prefix}-redis-inbound-allow"
  vpc_id = var.network_id
}

resource "aws_security_group_rule" "redis" {
  security_group_id = aws_security_group.redis_inbound_allow.id
  type              = "ingress"
  from_port         = var.redis_port
  to_port           = (var.redis_port)
  protocol          = "tcp"
  cidr_blocks       = var.network_private_subnet_cidrs
}

resource "aws_security_group_rule" "ssh_inbound" {

  security_group_id = aws_security_group.redis_inbound_allow.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.network_private_subnet_cidrs
}

resource "aws_security_group_rule" "redis_inbound" {
  security_group_id = aws_security_group.redis_inbound_allow.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
}


# Allow all traffic outbound from Redis instances to www
resource "aws_security_group" "redis_outbound_allow" {
  name   = "${var.friendly_name_prefix}-redis-outbound-allow"
  vpc_id = var.network_id
}

resource "aws_security_group_rule" "redis_sentinel_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all traffic outbound from Redis Sentinel instances to TFE"

  security_group_id = aws_security_group.redis_outbound_allow.id
}
