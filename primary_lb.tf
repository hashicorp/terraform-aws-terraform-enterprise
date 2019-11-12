resource "aws_elb" "cluster_api" {
  # Lowered to be sure it's compliant with
  # https://github.com/kubernetes/apimachinery/blob/461753078381c979582f217a28eb759ebee5295d/pkg/util/validation/validation.go#L132
  name_prefix = lower(var.prefix)
  subnets     = module.common.private_subnets
  internal    = true

  cross_zone_load_balancing = true

  security_groups = [module.common.intra_vpc_and_egress_sg_id]

  idle_timeout = 3600 # for kubectl commands

  listener {
    instance_protocol = "TCP"
    instance_port     = 6443

    lb_protocol = "TCP"
    lb_port     = 6443
  }

  listener {
    instance_protocol = "HTTP"
    instance_port     = 23010

    lb_protocol = "HTTP"
    lb_port     = 23010
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    target              = "HTTPS:6443/healthz"
    interval            = 10
    timeout             = 5
  }

  tags = {
    Name = var.prefix
  }
}

