resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg-"
  description = "Allow all ingress and egress for testing"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] # All IPv4 addresses
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # or restrict to trusted IPs
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
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

# Create an instance profile for the nginx instance
resource "aws_iam_instance_profile" "nginx_instance_profile" {
  name = "nginx-instance-profile"
  role = aws_iam_role.nginx_instance_role.name
}

resource "aws_instance" "postgres" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ec2_sg.name]
  iam_instance_profile        = aws_iam_instance_profile.nginx_instance_profile.name
  key_name                    = aws_key_pair.ec2_key.key_name

  user_data = templatefile("${path.module}/templates/startup.sh.tpl", {
    POSTGRES_USER     = var.db_username
    POSTGRES_PASSWORD = "postgres_postgres"
    # password          = random_string.postgresql_password.result
    POSTGRES_DB = var.db_name
  })

  tags = {
    Name = "Terraform-Postgres"
  }
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/ec2-postgres-key.pem"
  file_permission = "0600"
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-postgres-key"
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

  provisioner "file" {
    source      = "${path.module}/templates/certificate_generate.sh"
    destination = "/home/ubuntu/certificate_generate.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/certificate_generate.sh",
      "sudo /home/ubuntu/certificate_generate.sh"
    ]
  }
}


resource "null_resource" "configure_mtls" {
  depends_on = [
    null_resource.generate_certificates, # <- Make sure certs are copied before this
    aws_instance.postgres
  ]
  connection {
    type        = "ssh"
    user        = "ubuntu" # or "ec2-user" for Amazon Linux
    private_key = tls_private_key.ssh.private_key_pem
    host        = aws_instance.postgres.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/templates/setup-mtls.sh" # local path to script
    destination = "/home/ubuntu/setup-mtls.sh"             # remote path
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/setup-mtls.sh",
      "sudo /home/ubuntu/setup-mtls.sh"
    ]
  }
}
