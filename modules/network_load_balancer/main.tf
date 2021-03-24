resource "aws_lb" "tfe_lb" {
  name               = "${var.friendly_name_prefix}-tfe-web-alb"
  internal           = var.load_balancing_scheme
  load_balancer_type = "network"
  subnets            = var.network_public_subnets

  tags = var.common_tags
}

resource "aws_lb_listener" "tfe_listener_443" {
  load_balancer_arn = aws_lb.tfe_lb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_tg_443.arn
  }
}

resource "aws_lb_target_group" "tfe_tg_443" {
  name     = "${var.friendly_name_prefix}-tfe-alb-tg-443"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.network_id

  health_check {
    protocol = "TCP"
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "tfe_listener_8800" {
  count             = var.active_active ? 0 : 1
  load_balancer_arn = aws_lb.tfe_lb.arn
  port              = 8800
  protocol          = "TCP"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_tg_8800[0].arn
  }
}

resource "aws_lb_target_group" "tfe_tg_8800" {
  count    = var.active_active ? 0 : 1
  name     = "${var.friendly_name_prefix}-tfe-alb-tg-8800"
  port     = 8800
  protocol = "TCP"
  vpc_id   = var.network_id

  health_check {
    path     = "/"
    protocol = "TCP"
  }

  tags = var.common_tags
}

data "aws_route53_zone" "tfe" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "tfe" {
  zone_id = data.aws_route53_zone.tfe.zone_id
  name    = var.fqdn
  type    = "A"

  alias {
    name                   = aws_lb.tfe_lb.dns_name
    zone_id                = aws_lb.tfe_lb.zone_id
    evaluate_target_health = true
  }
}