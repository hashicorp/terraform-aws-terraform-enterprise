# Test: Active/Active Terraform Enterprise on RHEL with Proxy

## About this test

This test for Terraform Enterprise creates a TFE installation with the
following traits:

- Active/Active mode
- a small VM machine type (m5.xlarge)
- Red Hat 7.8 as the VM image
- a publicly accessible HTTP load balancer with TLS termination
- a proxy server with TLS termination
- an access key for accessing S3

## Pre-requisites

This test assumes the following resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate
- a TFE license on a filepath accessible by tests

## How this test is used

This test is leveraged by the integration tests in the
`ptfe-replicated` repository.
