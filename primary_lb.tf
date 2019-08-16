resource "aws_elb" "cluster_api" {
  name_prefix = "ptfe"
  subnets     = ["${module.common.private_subnets}"]
  internal    = true

  cross_zone_load_balancing = true

  security_groups = ["${module.common.intra_vpc_and_egress_sg_id}"]

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
}
