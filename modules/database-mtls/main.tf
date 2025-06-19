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
  name = "nginx-instance-role"
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
  name = "nginx-instance-profile"
  role = aws_iam_role.nginx_instance_role.name
}

resource "aws_instance" "postgres" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.postgresql.id]
  iam_instance_profile        = aws_iam_instance_profile.nginx_instance_profile.name
  # key_name                    = aws_key_pair.ec2_key.key_name

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

# resource "local_file" "private_key_pem" {
#   content         = tls_private_key.ssh.private_key_pem
#   filename        = "${path.module}/ec2-postgres-key.pem"
#   file_permission = "0600"
# }
# resource "tls_private_key" "ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "ec2_key" {
#   key_name   = "ec2-postgres-key"
#   public_key = tls_private_key.ssh.public_key_openssh
# }
