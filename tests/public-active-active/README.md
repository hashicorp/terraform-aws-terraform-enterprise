# TEST: Public Active/Active Terraform Enterprise

## About this test

This test for Terraform Enterprise creates a TFE
installation with the following traits.

- Active/Active mode
- a small VM machine type (m5.xlarge)
- Ubuntu 20.04 as the VM image
- a publicly accessible HTTP load balancer with TLS termination
- no proxy server
- no Redis authentication
- no Redis encryption in transit

## Pre-requisites

This test assumes the following resources exist.

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate

## How this test is used

This test is leveraged by this repository's continuous integration setup which
leverages workspaces in a Terraform Cloud workspaces as a remote backend so that
Terraform state is preserved.
