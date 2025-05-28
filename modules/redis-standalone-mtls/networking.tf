# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## DNS Record for Redis Load Balancer
# -----------------------------------
data "aws_route53_zone" "tfe" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "sentinel" {
  zone_id = data.aws_route53_zone.tfe.zone_id
  name    = "${var.friendly_name_prefix}-redis"
  type    = "A"

  alias {
    name                   = aws_lb.redis_lb.dns_name
    zone_id                = aws_lb.redis_lb.zone_id
    evaluate_target_health = true
  }
}

# Network Load Balancer for Redis cluster
# ---------------------------------------

resource "aws_lb" "redis_lb" {
  name                             = "${var.friendly_name_prefix}-redis-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.network_subnets_private
  enable_cross_zone_load_balancing = true
  security_groups = [
    aws_security_group.id,
    aws_security_group.id,
  ]
}

# Network Load Balancer Listener and Target Group for Redis
# ---------------------------------------------------------

resource "aws_lb_listener" "redis_listener_redis" {
  count             = 4
  load_balancer_arn = aws_lb.redis_lb.arn
  port              = (var.redis_port + count.index)
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_tg_redis[count.index].arn
  }
}

resource "aws_lb_target_group" "redis_tg_redis" {
  count    = 4
  name     = "${var.friendly_name_prefix}-redis-tg-${var.redis_port + count.index}"
  port     = (var.redis_port + count.index)
  protocol = "TCP"
  vpc_id   = var.network_id

  health_check {
    protocol = "TCP"
  }
}



