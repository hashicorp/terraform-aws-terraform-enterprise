output "sg_lb_to_instance" {
  value = aws_security_group.lb_to_instance.id
}

output "lb_id" {
  value = aws_lb.ptfe.id
}

output "lb_endpoint" {
  value = aws_lb.ptfe.dns_name
}

output "endpoint" {
  value = local.endpoint
}

output "https_group" {
  value = aws_lb_target_group.https.arn
}

output "admin_group" {
  value = aws_lb_target_group.admin.arn
}
