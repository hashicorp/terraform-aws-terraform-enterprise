###### security group for proxy ######
resource "aws_security_group" "proxy" {
  name   = "${var.name}-sg-proxy-allow"
  vpc_id = var.vpc_id

  # Prefix removed until https://github.com/hashicorp/terraform-provider-aws/issues/19583 is resolved
  tags = {
    # Name = "${var.name}-sg-proxy-allow"
    Name = "sg-proxy-allow"
  }
}

resource "aws_security_group_rule" "proxy_ingress_mitmproxy" {
  type        = "ingress"
  from_port   = var.http_proxy_port
  to_port     = var.http_proxy_port
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

##### IAM role for proxy #####

resource "aws_iam_instance_profile" "proxy" {
  name_prefix = "${var.name}-proxy"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.name}-proxy"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance_role.name
  policy_arn = local.ssm_policy_arn
}

##### proxy instance #####

resource "aws_iam_role_policy" "secretsmanager" {
  count  = local.mitmproxy_selected ? 1 : 0
  policy = data.aws_iam_policy_document.secretsmanager[count.index].json
  role   = aws_iam_role.instance_role.id

  name = "${var.name}-proxy-secretsmanager"
}

resource "aws_instance" "proxy" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "m4.xlarge"

  iam_instance_profile = aws_iam_instance_profile.proxy.name
  key_name             = var.key_name
  subnet_id            = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.proxy.id
  ]

  user_data = base64encode(local.mitmproxy_selected ? (
    module.test_proxy_init.mitmproxy.user_data_script
  ) : module.test_proxy_init.squid.user_data_script)

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }
}

module "test_proxy_init" {
  source = "github.com/hashicorp/terraform-random-tfe-utility//fixtures/test_proxy_init?ref=main"

  mitmproxy_ca_certificate_secret = var.mitmproxy_ca_certificate_secret != null ? var.mitmproxy_ca_certificate_secret : null
  mitmproxy_ca_private_key_secret = var.mitmproxy_ca_private_key_secret != null ? var.mitmproxy_ca_private_key_secret : null
  cloud                           = "aws"
}