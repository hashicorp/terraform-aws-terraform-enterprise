# EXAMPLE: Standalone Airgap Installation of Terraform Enterprise

## About this Example

This example deployment of Terraform Enterprise creates a TFE installation with the following traits.

- Standalone mode
- Airgapped installation
- a small VM machine type (m5.xlarge)
- Ubuntu 20.04 as the VM image
- a publicly accessible HTTP load balancer with TLS termination
- no proxy server

## Pre-requisites

This example assumes the following resources exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate
- TFE license on a filepath accessible by tests
- The URL of an airgap package
