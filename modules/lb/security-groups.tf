locals {
  publ_priv_subnet_cidr_blocks = concat(var.public_subnets_cidr_blocks, var.private_subnets_cidr_blocks)
}

resource "aws_security_group" "lb_to_instance" {
  description = "allow access to instances from the lb"
  vpc_id      = var.vpc_id

  ingress {
    description = "ssh, because debugging"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = local.publ_priv_subnet_cidr_blocks
  }

  ingress {
    description = "https to ptfe application"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = local.publ_priv_subnet_cidr_blocks
  }

  ingress {
    description = "https to replicated console"
    protocol    = "tcp"
    from_port   = 8800
    to_port     = 8800
    cidr_blocks = local.publ_priv_subnet_cidr_blocks
  }
}

resource "aws_security_group" "lb_public" {
  description = "allow access to ptfe and replicated console"
  vpc_id      = var.vpc_id

  ingress {
    description = "ssh, because debugging"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http to ptfe application"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https to ptfe application"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https to replicated console"
    protocol    = "tcp"
    from_port   = 8800
    to_port     = 8800
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all access to instances"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.private_subnets_cidr_blocks
  }

  egress {
    description = "allow all access to instances"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.public_subnets_cidr_blocks
  }
}
