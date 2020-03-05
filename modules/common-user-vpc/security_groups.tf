resource "aws_security_group" "intra_vpc_ingress_and_egress" {
  description = "allow instances to talk to each other, and set up trusted ingress and egress"
  vpc_id      = var.vpc_id
  name        = "${var.prefix}-${random_string.install_id.result}-intra-cluster-and-trusted-blocks"

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    self      = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.egress_allow_list
  }

  dynamic "ingress" {
    for_each = var.ingress_allow_list
    content {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ingress.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}"
    },
  )
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

  tags = var.tags
}
