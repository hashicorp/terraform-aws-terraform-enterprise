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

resource "aws_lb_listener" "redis_sentinel_listener_6379" {
  load_balancer_arn = aws_lb.redis_sentinel_lb.arn
  port              = 6379
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_sentinel_tg_6379.arn
  }
}

resource "aws_lb_target_group" "redis_sentinel_tg_6379" {
  name     = "${var.friendly_name_prefix}-redis-sentinel-tg-6379"
  port     = 6379
  protocol = "TCP"
  vpc_id   = var.network_id

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "redis_sentinel_listener_26379" {
  load_balancer_arn = aws_lb.redis_sentinel_lb.arn
  port              = 26379
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_sentinel_tg_26379.arn
  }
}

resource "aws_lb_target_group" "redis_sentinel_tg_26379" {
  name     = "${var.friendly_name_prefix}-redis-sentinel-tg-26379"
  port     = 26379
  protocol = "TCP"
  vpc_id   = var.network_id

  health_check {
    protocol = "TCP"
  }
}
