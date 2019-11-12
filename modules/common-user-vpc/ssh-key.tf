## mostly copied from https://github.com/cloudposse/terraform-aws-key-pair,
## which has some problems with their label module (recursively included).

locals {
  ssh_public_key_path = "${path.root}/work"
  key_name            = "${var.prefix}-${random_string.install_id.result}"

  public_key_filename  = "${local.ssh_public_key_path}/${local.key_name}.pub"
  private_key_filename = "${local.ssh_public_key_path}/${local.key_name}.priv"
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  key_name   = local.key_name
  public_key = tls_private_key.default.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.default.private_key_pem
  filename = local.private_key_filename
}

resource "null_resource" "chmod" {
  triggers = {
    key_data = local_file.private_key_pem.content
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_filename}"
  }
}
