resource "random_string" "postgres_db_password" {
  length           = 128
  special          = true
  override_special = "#$%&*"
}

# resource "aws_lb" "redis_lb" {
#   name                             = "${var.friendly_name_prefix}-redis-nlb"
#   internal                         = true
#   load_balancer_type               = "network"
#   subnets                          = var.network_subnets_private
#   enable_cross_zone_load_balancing = true
#   security_groups = [
#     aws_security_group.postgres_db_sg.id,
#   ]
# }

# resource "aws_lb_target_group" "redis_tg" {
#   name     = "${var.friendly_name_prefix}-redis-tg-5432"
#   port     = 5432
#   protocol = "TCP"
#   vpc_id   = var.network_id

#   health_check {
#     protocol = "TCP"
#   }
# }


# Network Load Balancer Listener and Target Group for Redis
# ---------------------------------------------------------

# resource "aws_lb_listener" "redis_listener_redis" {
#   load_balancer_arn = aws_lb.redis_lb.arn
#   port              = 5432
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.redis_tg.arn
#   }
# }

data "aws_route53_zone" "postgres_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "postgres_db_dns" {
  zone_id = data.aws_route53_zone.postgres_zone.zone_id
  name    = "${var.friendly_name_prefix}-postgres-mtls"
  type    = "A"
  ttl     = 300

  records = [aws_instance.postgres_db_instance.public_ip]
}

resource "aws_security_group" "postgres_db_sg" {
  description = "The security group of the PostgreSQL deployment for TFE."
  name        = "${var.friendly_name_prefix}-postgres-mtls"
  vpc_id      = data.aws_vpc.default
}

resource "aws_security_group_rule" "postgres_db_ingress" {
  security_group_id = aws_security_group.postgres_db_sg.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "postgres_db_ssh_ingress" {
  security_group_id = aws_security_group.postgres_db_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "postgres_db_egress" {
  security_group_id = aws_security_group.postgres_db_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "postgres_db_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "m5.xlarge"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.postgres_db_sg.id]
  iam_instance_profile        = var.aws_iam_instance_profile
  key_name                    = aws_key_pair.ec2_key.key_name
  subnet_id                   = var.network_public_subnets[0]
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 100
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = "Terraform-Postgres-mTLS"
  }

  user_data = templatefile("${path.module}/templates/certificate_generate.sh", {
    POSTGRES_USER        = var.db_username
    POSTGRES_PASSWORD    = random_string.postgres_db_password.result
    POSTGRES_DB          = var.db_name
    POSTGRES_CLIENT_CERT = var.postgres_client_certificate_secret_id
    POSTGRES_CLIENT_KEY  = var.postgres_client_key_secret_id
    POSTGRES_CLIENT_CA   = var.postgres_ca_certificate_secret_id
  })
}

resource "local_file" "postgres_db_private_key" {
  content         = tls_private_key.postgres_db_ssh_key.private_key_pem
  filename        = "${path.module}/${var.friendly_name_prefix}-ec2-postgres-key.pem"
  file_permission = "0600"
}
resource "tls_private_key" "postgres_db_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.friendly_name_prefix}-ec2-postgres-key"
  public_key = tls_private_key.postgres_db_ssh_key.public_key_openssh
}


# resource "null_resource" "postgres_db_cert_generation" {
#   depends_on = [aws_route53_record.postgres_db_dns]

#   triggers = {
#     instance_ip = aws_instance.postgres_db_instance.public_ip
#   }

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = tls_private_key.postgres_db_ssh_key.private_key_pem
#     host        = aws_route53_record.postgres_db_dns.fqdn
#   }

#   provisioner "file" {
#     source      = "${path.module}/templates/certificate_generate.sh"
#     destination = "/home/ubuntu/certificate_generate.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sleep 60",
#       "chmod +x /home/ubuntu/certificate_generate.sh",
#       "sudo POSTGRES_PASSWORD='${random_string.postgres_db_password.result}' POSTGRES_USER=${var.db_username} POSTGRES_DB=${var.db_name} POSTGRES_CLIENT_CERT=${var.postgres_client_certificate_secret_id} POSTGRES_CLIENT_KEY=${var.postgres_client_key_secret_id} POSTGRES_CLIENT_CA=${var.postgres_ca_certificate_secret_id} /home/ubuntu/certificate_generate.sh"
#     ]
#   }
# }
