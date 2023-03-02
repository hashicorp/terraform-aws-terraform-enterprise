# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

###### Security Group For Bastion ######

resource "aws_security_group" "bastion" {
  name   = "${var.name}-sg-bastion-allow"
  vpc_id = var.vpc_id

  # Prefix removed until https://github.com/hashicorp/terraform-provider-aws/issues/19583 is resolved
  tags = {
    # Name = "${var.name}-sg-bastion-allow"
    Name = "sg-bastion-allow"
  }
}

resource "aws_security_group_rule" "bastion_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow TFE traffic to bastion instance"

  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all egress traffic from bastion instance"

  security_group_id = aws_security_group.bastion.id
}

##### IAM Role For Bastion #####

resource "aws_iam_instance_profile" "bastion" {
  name_prefix = "${var.name}-bastion"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.name}-bastion"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance_role.name
  policy_arn = local.ssm_policy_arn
}

##### Bastion Host Instance #####

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "m4.xlarge"

  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name             = var.key_name
  subnet_id            = var.subnet_id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }
}
