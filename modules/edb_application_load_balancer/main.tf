# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_security_group" "edb_lb_allow" {
  name   = "${var.friendly_name_prefix}-edb-lb-allow"
  vpc_id = var.network_id
}

resource "aws_security_group_rule" "edb_lb_allow_inbound_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP (port 80) traffic inbound to EDB LB"
  security_group_id = aws_security_group.edb_lb_allow.id
}

resource "aws_security_group_rule" "edb_lb_allow_inbound_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS (port 443) traffic inbound to EDB LB"
  security_group_id = aws_security_group.edb_lb_allow.id
}

resource "aws_security_group_rule" "edb_lb_allow_inbound_postgres" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow Postgres (port 80) traffic inbound to EDB LB"
  security_group_id = aws_security_group.edb_lb_allow.id
}


resource "aws_security_group" "edb_outbound_allow" {
  name   = "${var.friendly_name_prefix}-edb-outbound-allow"
  vpc_id = var.network_id
}

resource "aws_security_group_rule" "edb_outbound_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all traffic outbound from edb"

  security_group_id = aws_security_group.edb_outbound_allow.id
}

resource "aws_lb" "edb_lb" {
  name               = "${var.friendly_name_prefix}-edb-web-alb"
  internal           = (var.load_balancing_scheme == "PRIVATE")
  load_balancer_type = "application"
  subnets            = var.load_balancing_scheme == "PRIVATE" ? var.network_private_subnets : var.network_public_subnets

  security_groups = [
    aws_security_group.edb_lb_allow.id,
    aws_security_group.edb_outbound_allow.id
  ]
}

resource "aws_lb_listener" "edb_listener_80" {
  load_balancer_arn = aws_lb.edb_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.edb_tg_80.arn
  }

}

resource "aws_lb_target_group" "edb_tg_80" {
  name     = "${var.friendly_name_prefix}-edb-alb-tg-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.network_id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "edb_listener_5432" {
  load_balancer_arn = aws_lb.edb_lb.arn
  port              = 5432
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.edb_tg_5432.arn
  }
}

resource "aws_lb_target_group" "edb_tg_5432" {
  name     = "${var.friendly_name_prefix}-edb-alb-tg-5432"
  port     = 5432
  protocol = "HTTPS"
  vpc_id   = var.network_id

  health_check {
    path     = "/"
    protocol = "HTTPS"
    matcher  = "200-499"
  }
}


data "aws_route53_zone" "edb" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "edb" {
  zone_id = data.aws_route53_zone.edb.zone_id
  name    = var.fqdn
  type    = "A"

  alias {
    name                   = aws_lb.edb_lb.dns_name
    zone_id                = aws_lb.edb_lb.zone_id
    evaluate_target_health = true
  }
}
