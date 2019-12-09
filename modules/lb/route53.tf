resource "aws_route53_record" "ptfe_lb" {
  count = var.update_route53 ? 1 : 0

  zone_id = data.aws_route53_zone.zone[count.index].zone_id
  name    = local.endpoint
  type    = "A"

  alias {
    name    = aws_lb.ptfe.dns_name
    zone_id = aws_lb.ptfe.zone_id

    evaluate_target_health = false
  }
}
