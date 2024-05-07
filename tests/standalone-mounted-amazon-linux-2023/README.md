# EXAMPLE: Standalone Mounted Installation of Terraform Enterprise

## About This Test

This test for Terraform Enterprise creates a TFE installation on Replicated with the following traits:

- Standalone
- Mounted Disk production type
- m5.xlarge virtual machine type
- Amazon Linux 2023
- A publicly accessible HTTP load balancer with TLS termination


## Pre-requisites

This test assumes the following resources exist.

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate

## How this test is used

This test is leveraged by this repository's continuous integration setup which
leverages workspaces in a Terraform Cloud workspaces as a remote backend so that
Terraform state is preserved.
