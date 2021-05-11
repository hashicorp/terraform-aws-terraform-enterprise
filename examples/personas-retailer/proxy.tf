data "template_cloudinit_config" "config_proxy" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/templates/cloud-config-proxy.yaml",
      {
        http_proxy_port = local.http_proxy_port
      }
    )
  }
}

resource "aws_instance" "proxy" {
  ami           = data.aws_ami.rhel.id
  instance_type = var.squid_instance_type

  subnet_id = module.retailer_deployment.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.proxy.id,
  ]

  user_data = data.template_cloudinit_config.config_proxy.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = var.squid_volume_size

  }
}

resource "aws_security_group" "proxy" {
  name   = "${local.complete_prefix}-sg-proxy-allow"
  vpc_id = module.retailer_deployment.network_id

  tags = merge(
    { Name = "${local.complete_prefix}-sg-proxy-allow" },
    var.common_tags
  )
}

resource "aws_security_group_rule" "proxy_ingress" {
  type        = "ingress"
  from_port   = local.http_proxy_port
  to_port     = local.http_proxy_port
  protocol    = "tcp"
  cidr_blocks = module.retailer_deployment.network_private_subnet_cidrs
  description = "Allow internal traffic to proxy instance"

  security_group_id = aws_security_group.proxy.id
}

resource "aws_security_group_rule" "proxy_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all egress traffic from proxy instance"

  security_group_id = aws_security_group.proxy.id
}
