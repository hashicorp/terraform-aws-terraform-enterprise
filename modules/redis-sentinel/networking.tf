# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## DNS Record for Redis Sentinel cluster Load Balancer
# ----------------------------------------------------
data "aws_route53_zone" "tfe" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "sentinel" {
  zone_id = data.aws_route53_zone.tfe.zone_id
  name    = "${var.friendly_name_prefix}-redis-sentinel"
  type    = "A"

  alias {
    name                   = aws_lb.redis_sentinel_lb.dns_name
    zone_id                = aws_lb.redis_sentinel_lb.zone_id
    evaluate_target_health = true
  }
}

# Network Load Balancer for Redis Sentinel cluster
# ------------------------------------------------

resource "aws_lb" "redis_sentinel_lb" {
  name               = "${var.friendly_name_prefix}-redis-sentinel-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.network_subnets_private
}

# Network Load Balancer Listener and Target Group for Redis and Sentinel
# ----------------------------------------------------------------------

resource "aws_lb_listener" "redis_sentinel_listener_redis" {
  count = 4
  load_balancer_arn = aws_lb.redis_sentinel_lb.arn
  port              = (var.redis_port+count.index)
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_sentinel_tg_redis[count.index].arn
  }
}

resource "aws_lb_target_group" "redis_sentinel_tg_redis" {
  count = 4
  name     = "${var.friendly_name_prefix}-redis-sentinel-tg-${var.redis_port+count.index}"
  port     = (var.redis_port+count.index)
  protocol = "TCP"
  vpc_id   = var.network_id

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "redis_sentinel_listener_sentinel" {
  count = 2
  load_balancer_arn = aws_lb.redis_sentinel_lb.arn
  port              = (var.redis_sentinel_port+count.index)
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_sentinel_tg[count.index].arn
  }
}

resource "aws_lb_target_group" "redis_sentinel_tg" {
  count = 2
  name     = "${var.friendly_name_prefix}-redis-sentinel-tg-${var.redis_sentinel_port+count.index}"
  port     = (var.redis_sentinel_port+count.index)
  protocol = "TCP"
  vpc_id   = var.network_id

  health_check {
    protocol = "TCP"
  }
}
