resource "aws_lb" "ptfe" {
  subnets            = var.public_subnets
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.lb_public.id,
    aws_security_group.lb_to_instance.id,
  ]

  idle_timeout = 3600 ## for ssh

  tags = {
    Name = var.prefix
  }
}

resource "aws_lb_target_group" "https" {
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/_health_check"
    protocol = "HTTPS"
  }
}

resource "aws_lb_target_group" "admin" {
  port     = 8800
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTPS"
    matcher  = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ptfe.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ptfe.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn != "" ? var.cert_arn : data.aws_acm_certificate.lb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_listener" "admin" {
  load_balancer_arn = aws_lb.ptfe.arn
  port              = "8800"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn != "" ? var.cert_arn : data.aws_acm_certificate.lb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin.arn
  }
}
