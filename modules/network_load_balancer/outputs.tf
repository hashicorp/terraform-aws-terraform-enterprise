output "aws_lb_target_group_tfe_tg_443_arn" {
  value = aws_lb_target_group.tfe_tg_443.arn
}

output "aws_lb_target_group_tfe_tg_8800_arn" {
  value = var.active_active ? null : aws_lb_target_group.tfe_tg_8800[0].arn
}

output "load_balancer_address" {
  value = aws_lb.tfe_lb.dns_name
}
