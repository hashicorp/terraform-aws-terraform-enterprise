resource "aws_security_group" "postgresql" {
  description = "The security group of the PostgreSQL deployment for TFE."
  name        = "${var.friendly_name_prefix}-tfe-postgres-mtls"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "postgresql_ingress" {
  security_group_id = aws_security_group.postgresql.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "postgresql_ingress_all" {
  security_group_id = aws_security_group.postgresql.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "postgresql_tfe_egress" {
  security_group_id = aws_security_group.postgresql.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Define the IAM role for the nginx instance
resource "aws_iam_role" "nginx_instance_role" {
  name = "${var.friendly_name_prefix}-nginx-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_instance_profile" "nginx_instance_profile" {
  name = "${var.friendly_name_prefix}-nginx-instance-profile"
  role = aws_iam_role.nginx_instance_role.name
}

resource "aws_instance" "postgres" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.postgresql.id]
  iam_instance_profile        = aws_iam_instance_profile.nginx_instance_profile.name
  key_name                    = aws_key_pair.ec2_key.key_name

  user_data = templatefile("${path.module}/templates/startup.sh.tpl", {
    POSTGRES_USER     = var.db_username
    POSTGRES_PASSWORD = "postgres_postgres"
    # password          = random_string.postgresql_password.result
    POSTGRES_DB = var.db_name
  })

  tags = {
    Name = "Terraform-Postgres-mTLS"
  }
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/${var.friendly_name_prefix}-ec2-postgres-key.pem"
  file_permission = "0600"
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.friendly_name_prefix}-ec2-postgres-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "null_resource" "generate_certificates" {
  depends_on = [aws_instance.postgres]

  triggers = {
    always_run = timestamp()
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh.private_key_pem
    host        = aws_instance.postgres.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "echo '===== Startup Script Logs ====='",
      "sudo cat /home/ubuntu/startup.log || echo '❌ Log file not found.'"
    ]
  }
}

# resource "null_resource" "download_certs" {
#   depends_on = [null_resource.generate_certificates]

#   provisioner "local-exec" {
#     command = <<EOT
#     mkdir -p ./tfe-certs
#     scp -i ${path.module}/ec2-postgres-key.pem \
#         -o StrictHostKeyChecking=no \
#         ubuntu@${aws_instance.postgres.public_ip}:/home/ubuntu/mtls-certs/* \
#         ./tfe-certs/
#     EOT
#   }
# }

# resource "null_resource" "move_certs_to_bind" {
#   depends_on = [null_resource.download_certs]

#   provisioner "local-exec" {
#     command = <<EOT
#     sudo mkdir -p /etc/tfe/ssl/postgres
#     sudo cp ./tfe-certs/ca.crt     /etc/tfe/ssl/postgres/cacert.pem
#     sudo cp ./tfe-certs/client.crt /etc/tfe/ssl/postgres/cert.pem
#     sudo cp ./tfe-certs/client.key /etc/tfe/ssl/postgres/key.pem
#     sudo chmod 600 /etc/tfe/ssl/postgres/*
#     EOT
#   }
# }
