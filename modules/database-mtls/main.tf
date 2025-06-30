data "aws_route53_zone" "postgres_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "postgres" {
  zone_id = data.aws_route53_zone.postgres_zone.zone_id
  name    = "${var.friendly_name_prefix}-postgres-mtls"
  type    = "A"
  ttl     = 300

  records = [aws_instance.postgres.public_ip]
}

resource "aws_security_group" "postgresql" {
  description = "The security group of the PostgreSQL deployment for TFE."
  name        = "${var.friendly_name_prefix}-postgres-mtls"
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

resource "aws_security_group_rule" "postgresql_ingress_ssh" {
  security_group_id = aws_security_group.postgresql.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
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

resource "aws_instance" "postgres" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "m5.xlarge"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.postgresql.id]
  iam_instance_profile        = var.aws_iam_instance_profile
  key_name                    = aws_key_pair.ec2_key.key_name

  # user_data = templatefile("${path.module}/templates/startup.sh", {
  #   POSTGRES_USER     = var.db_username
  #   POSTGRES_PASSWORD = "postgres_postgres"
  #   # password          = random_string.postgresql_password.result
  #   POSTGRES_DB          = var.db_name
  #   postgres_client_cert = var.postgres_client_certificate_secret_id
  #   postgres_client_key  = var.postgres_client_key_secret_id
  #   postgres_client_ca   = var.postgres_ca_certificate_secret_id
  # })

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 100  # Size in GiB
    delete_on_termination = true # Deletes EBS when instance is terminated
    encrypted             = true # Enable encryption
  }

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
    instance_ip = aws_instance.postgres.public_ip
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh.private_key_pem
    host        = aws_instance.postgres.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/templates/certificate_generate.sh"
    destination = "/home/ubuntu/certificate_generate.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '⏳ Waiting 60 seconds before running certificate script...'",
      "sleep 60",
      "chmod +x /home/ubuntu/certificate_generate.sh",
      "sudo postgres_client_cert=${var.postgres_client_certificate_secret_id} postgres_client_key=${var.postgres_client_key_secret_id} postgres_client_ca=${var.postgres_ca_certificate_secret_id} /home/ubuntu/certificate_generate.sh"
    ]
  }
}
# resource "null_resource" "download_certs" {
#   depends_on = [null_resource.generate_certificates]

#   provisioner "local-exec" {
#     command = <<EOT
#     set -e
#     echo "📁 Creating local directory ./tfe-certs..."
#     mkdir -p ./tfe-certs

#     echo "⬇️  Downloading certificates from EC2 instance at ${aws_instance.postgres.public_ip}..."
#     scp -i ${path.module}/${var.friendly_name_prefix}-ec2-postgres-key.pem \
#         -o StrictHostKeyChecking=no \
#         ubuntu@${aws_instance.postgres.public_ip}:/home/ubuntu/mtls-certs/* \
#         ./tfe-certs/

#     if [ $? -eq 0 ]; then
#       echo "✅ Certificates successfully downloaded to ./tfe-certs."
#     else
#       echo "❌ Failed to download certificates."
#       exit 1
#     fi
#     EOT
#   }
# }

# data "local_file" "ca_cert" {
#   depends_on = [null_resource.download_certs]
#   filename   = "./tfe-certs/ca.crt"
# }

# 3. Secrets Manager using content from the file
# resource "aws_secretsmanager_secret_version" "database_mtls_client_ca" {
#   depends_on = [null_resource.download_certs]
#   # secret_binary = filebase64("./tfe-certs/ca.crt")
#   secret_binary = base64encode("exampledata")
#   secret_id     = aws_secretsmanager_secret.database_mtls_client_ca.id
# }
# resource "aws_secretsmanager_secret" "database_mtls_client_ca" {
#   depends_on  = [null_resource.download_certs]
#   name        = "database_mtls_client_ca-${var.friendly_name_prefix}2"
#   description = "LetsEncrypt root certificate"
# }

# resource "null_resource" "move_certs_to_bind" {
#   depends_on = [null_resource.download_certs]

#   provisioner "local-exec" {
#     command = <<EOT
#     set -e
#     echo "📂 Creating destination directory /etc/tfe/ssl/postgres..."
#     mkdir -p /etc/tfe/ssl/postgres

#     echo "📦 Moving certificates into place..."
#     cp ./tfe-certs/ca.crt     /etc/tfe/ssl/postgres/ca.crt
#     cp ./tfe-certs/client.crt /etc/tfe/ssl/postgres/client.crt
#     cp ./tfe-certs/client.key /etc/tfe/ssl/postgres/client.key

#     echo "🔐 Securing client key permissions..."
#     chmod 600 /etc/tfe/ssl/postgres/client.key

#     echo "✅ Certificates successfully moved and secured."
#     EOT
#   }
# }



