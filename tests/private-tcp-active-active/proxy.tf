resource "aws_security_group" "proxy" {
  name   = "${random_string.friendly_name.result}-sg-proxy-allow"
  vpc_id = module.private_tcp_active_active.network_id

  tags = merge(
    { Name = "${random_string.friendly_name.result}-sg-proxy-allow" },
    local.common_tags
  )
}

resource "aws_security_group_rule" "proxy_ingress_mitmproxy" {
  type        = "ingress"
  from_port   = local.http_proxy_port
  to_port     = local.http_proxy_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow TFE traffic to proxy instance"

  security_group_id = aws_security_group.proxy.id
}

resource "aws_security_group_rule" "proxy_ingress_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow SSH to proxy instance"

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

resource "aws_instance" "proxy" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "m4.xlarge"

  subnet_id = module.private_tcp_active_active.public_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.proxy.id
  ]

  user_data = base64encode(
    templatefile(
      "${path.module}/templates/mitmproxy.sh.tpl",
      {
        certificate     = tls_self_signed_cert.ca.cert_pem
        http_proxy_port = local.http_proxy_port
        private_key     = tls_private_key.ca.private_key_pem
      }
    )
  )

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }
}
