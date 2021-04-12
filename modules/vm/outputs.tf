output "tfe_instance_sg" {
  value = aws_security_group.tfe_instance.id

  description = "The identity of the security group attached to the TFE EC2 instance."
}

