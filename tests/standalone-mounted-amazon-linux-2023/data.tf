data "aws_secretsmanager_secret" "vm_key" {
  name = "wildcard-private-key-pem"
}

data "aws_secretsmanager_secret" "vm_certificate" {
  name = "wildcard-chained-certificate-pem"
}


data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}