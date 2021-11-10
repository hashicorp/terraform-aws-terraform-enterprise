resource "aws_security_group" "proxy" {
  name   = "${local.friendly_name_prefix}-sg-proxy-allow"
  vpc_id = module.tfe.network_id

  # Prefix removed until https://github.com/hashicorp/terraform-provider-aws/issues/19583 is resolved
  tags = {
    # Name = "${local.friendly_name_prefix}-sg-proxy-allow"
    Name = "sg-proxy-allow"
  }
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

resource "aws_security_group_rule" "proxy_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all egress traffic from proxy instance"

  security_group_id = aws_security_group.proxy.id
}

resource "aws_iam_instance_profile" "proxy" {
  name_prefix = "${local.friendly_name_prefix}-proxy"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${local.friendly_name_prefix}-proxy"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance_role.name
  policy_arn = local.ssm_policy_arn
}

resource "aws_iam_role_policy" "secretsmanager" {
  policy = data.aws_iam_policy_document.secretsmanager.json
  role   = aws_iam_role.instance_role.id

  name = "${local.friendly_name_prefix}-proxy-secretsmanager"
}

resource "aws_instance" "proxy" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "m4.xlarge"

  iam_instance_profile = aws_iam_instance_profile.proxy.name
  subnet_id            = module.tfe.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.proxy.id
  ]

  user_data = base64encode(
    templatefile(
      "${path.module}/templates/mitmproxy.sh.tpl",
      {
        certificate_secret = data.aws_secretsmanager_secret.ca_certificate
        http_proxy_port    = local.http_proxy_port
        private_key_secret = data.aws_secretsmanager_secret.ca_private_key
      }
    )
  )

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }
}
