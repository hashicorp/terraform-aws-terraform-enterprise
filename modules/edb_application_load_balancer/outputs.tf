# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "aws_lb_security_group" {
  value = aws_security_group.edb_lb_allow.id

  description = "The identity of the security group attached to the load balancer."
}

output "aws_lb_target_group_edb_tg_80_arn" {
  value = aws_lb_target_group.edb_tg_80.arn

  description = "The Amazon Resource Name of the load balancer target group for traffic on port 80."
}

output "load_balancer_address" {
  value = aws_lb.edb_lb.dns_name

  description = "The DNS name of the load balancer."
}
