resource "aws_security_group" "intra_vpc_and_egress" {
  description = "allow instances to talk to each other, and have unfettered egress"
  vpc_id      = var.vpc_id

  # NOTE: you cannot (should not) mix in-line ingress/egress rules with the
  # aws_security_group_rule resource
  # https://www.terraform.io/docs/providers/aws/r/security_group_rule.html

  tags = {
    Name = "${var.prefix}"
  }
}

resource "aws_security_group_rule" "intra_vpc_and_egress_ingress_rule" {
  security_group_id = "${aws_security_group.intra_vpc_and_egress.id}"

  type = "ingress"

  protocol  = "-1"
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "intra_vpc_and_egress_egress_rule" {
  security_group_id = "${aws_security_group.intra_vpc_and_egress.id}"

  type        = "egress"
  description = "outbound access to the world"

  protocol  = "-1"
  from_port = 0
  to_port   = 0

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

# Allow whitelisted ranges to access our services.
# For example, an HTTP proxy.
resource "aws_security_group_rule" "allow_list" {
  count             = length(var.allow_list) > 0 ? 1 : 0
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = var.allow_list
  security_group_id = aws_security_group.intra_vpc_and_egress.id
}

resource "aws_security_group" "allow_ptfe" {
  name        = "ptfe ingress ${random_string.install_id.result}"
  description = "allow access to ptfe and replicated console"
  vpc_id      = var.vpc_id

  ingress {
    description = "ssh, because debugging"

    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http to ptfe application"

    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https to ptfe application"

    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https to replicated console"

    protocol  = "tcp"
    from_port = 8800
    to_port   = 8800

    cidr_blocks = ["0.0.0.0/0"]
  }
}
