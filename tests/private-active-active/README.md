# Test: Private Active/Active Terraform Enterprise

## About this test

This test for Terraform Enterprise creates a TFE installation with the
following traits:

- Active/Active mode
- a medium VM machine type (m5.4xlarge)
- Red Hat 7.8 as the VM image
- a privately accessible HTTP load balancer with TLS termination
- a proxy server with TLS pass-through
- Redis authentication
- no Redis encryption in transit

## Pre-requisites

This test assumes the following resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate

## How this test is used

This test is leveraged by this repository's continuous integration
setup which leverages a Terraform Cloud workspace as a
remote backend so that Terraform state is preserved.
