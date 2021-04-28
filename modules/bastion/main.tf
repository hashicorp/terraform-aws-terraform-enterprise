################
# BASTION HOST #
################

resource "aws_instance" "bastion" {
  count = var.deploy_bastion == true && var.deploy_vpc == true ? 1 : 0

  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = var.bastion_host_subnet
  vpc_security_group_ids      = [aws_security_group.bastion[0].id]
  key_name                    = var.bastion_keypair
  associate_public_ip_address = "true"
  user_data_base64            = var.user_data_base64

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
    kms_key_id  = var.kms_key_id
  }

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-bastion" },
    var.common_tags
  )

  metadata_options {
    http_tokens   = "optional"
    http_endpoint = "enabled"
  }

}

resource "aws_security_group" "bastion" {
  count = var.deploy_bastion == true && var.deploy_vpc == true ? 1 : 0

  name   = "${var.friendly_name_prefix}-sg-bastion-allow"
  vpc_id = var.network_id

  tags = merge(
    { Name = "${var.friendly_name_prefix}-sg-bastion-allow" },
    var.common_tags
  )
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  count = length(aws_security_group.bastion) > 0 ? 1 : 0

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.bastion_ingress_cidr_allow
  description = "Allow SSH to Bastion instance"

  security_group_id = aws_security_group.bastion[0].id
}

resource "aws_security_group_rule" "bastion_egress" {
  count = length(aws_security_group.bastion) > 0 ? 1 : 0

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all egress traffic from Bastion instance"

  security_group_id = aws_security_group.bastion[0].id
}

# Generate a keypair for bastion host to TFE instance connectivity

resource "tls_private_key" "tfe_bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_bastion_key" {
  key_name   = "${var.friendly_name_prefix}-tfe-bastion"
  public_key = tls_private_key.tfe_bastion.public_key_openssh
}
