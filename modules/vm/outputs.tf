output "tfe_instance_sg" {
  value = aws_security_group.tfe_instance.id

  description = "The identity of the security group attached to the TFE EC2 instance."
}

output "tfe_autoscaling_group" {
  value = aws_autoscaling_group.tfe_asg

  description = "The autoscaling group which hosts the TFE EC2 instance(s)."
}
