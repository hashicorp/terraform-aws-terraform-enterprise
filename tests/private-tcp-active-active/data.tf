data "aws_secretsmanager_secret" "ca_certificate" {
  name = var.ca_certificate_secret_name
}

data "aws_secretsmanager_secret" "ca_private_key" {
  name = var.ca_private_key_secret_name
}

data "aws_secretsmanager_secret" "tfe_license" {
  name = var.tfe_license_secret_name
}

data "aws_ami" "rhel" {
  owners = ["309956199498"] # RedHat

  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7.9_HVM-*-x86_64-*-Hourly2-GP2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "secretsmanager" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = [data.aws_secretsmanager_secret.ca_certificate.arn, data.aws_secretsmanager_secret.ca_private_key.arn]
    sid       = "AllowSecretsManagerSecretAccess"
  }
}
