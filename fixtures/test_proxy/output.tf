output "proxy_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.proxy.private_ip
}

output "proxy_instance_id" {
  value       = aws_instance.proxy.id
  description = "The ID of the proxy EC2 instance."
}