data "aws_secretsmanager_secret" "ca_certificate" {
  name = var.ca_certificate_secret_name
}

data "aws_secretsmanager_secret" "ca_private_key" {
  name = var.ca_private_key_secret_name
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
