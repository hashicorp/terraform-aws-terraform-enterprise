# EXAMPLE: Standalone - Mounted Disk Terraform Enterprise

## About this Example

This test for Terraform Enterprise creates a TFE
installation with the following traits.

- Standalone mode
- Mounted Disk operational mode
- a small VM machine type (m5.xlarge)
- Ubuntu 20.04 as the VM image
- a publicly accessible HTTP load balancer with TLS termination
- no proxy server

## Pre-requisites

This test assumes the following resources exist.

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate
- TFE license on a filepath accessible by tests
