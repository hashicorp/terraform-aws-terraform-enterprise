# EXAMPLE: Standalone, Airgapped Package Installation of Terraform Enterprise (bootstrapping with airgap prerequisites)

## About this example

This example for Terraform Enterprise creates a TFE
installation with the following traits.

- Standalone
- _Mocked_ Airgapped installation
- External mode
- a small VM machine type (m5.xlarge)
- Ubuntu 20.04 as the VM image
- a publicly accessible HTTP load balancer with TLS termination
- no proxy server

## Pre-requisites

This example merely tests that the `airgap_url` package is able to install TFE. It does
not, however, assume that the environment is air-gapped, and it therefore installs the
prerequisites for an air-gapped installation, too. This example assumes that the following
resources exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate
- TFE license on a filepath accessible by tests
- The URL of an airgap package
