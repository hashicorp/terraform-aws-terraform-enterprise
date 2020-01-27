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

  tags = {
    Name = "${var.prefix}"
  }
}
