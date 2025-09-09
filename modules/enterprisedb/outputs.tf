# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "enterprisedb_instance_sg" {
  value = aws_security_group.enterprisedb_instance.id

  description = "The identity of the security group attached to the EnterpriseDB EC2 instance."
}

output "enterprisedb_autoscaling_group" {
  value = aws_autoscaling_group.enterprisedb_asg

  description = "The autoscaling group which hosts the EnterpriseDB instance(s)."
}
