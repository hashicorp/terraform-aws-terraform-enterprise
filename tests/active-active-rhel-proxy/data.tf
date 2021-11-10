data "aws_secretsmanager_secret" "ca_certificate" {
  name = "terraform-20211022160427310700000001"
}

data "aws_secretsmanager_secret" "ca_private_key" {
  name = "terraform-20211022160427312200000003"
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

data "aws_iam_user" "object_storage" {
  user_name = var.object_storage_iam_user_name
}

data "aws_instances" "tfe" {
  instance_tags = local.common_tags

  depends_on = [
    null_resource.wait_for_instances
  ]
}

# This null_data_source is used to prevent Terraform from trying to render local_file.ssh_config file before data.
# aws_instances.tfe is available.
# See https://github.com/hashicorp/terraform-provider-local/issues/57
data "null_data_source" "instance" {
  inputs = {
    id = data.aws_instances.tfe.ids[0]
  }
}
