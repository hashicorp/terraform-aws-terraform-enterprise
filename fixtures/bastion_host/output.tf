# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "bastion_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.bastion.private_ip
}

output "bastion_instance_id" {
  value       = aws_instance.bastion.id
  description = "The ID of the bastion EC2 instance."
}
