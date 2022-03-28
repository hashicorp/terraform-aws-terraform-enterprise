output "proxy_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.proxy.private_ip
}
