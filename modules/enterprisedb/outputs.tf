# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "enterprisedb_instance_ipv4" {
  value = aws_instance.edb_server.private_ip

  description = "The ipv4 of the EnterpriseDB EC2 instance."
}

