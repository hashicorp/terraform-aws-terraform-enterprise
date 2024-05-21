# Test: Standalone with AWS Aurora RDS

## About this test

This test for Terraform Enterprise creates a TFE installation with the
following traits:

- External mode
- a small VM machine type (m5.xlarge)
- Red Hat 7.9 as the VM image
- a publicly accessible HTTP load balancer with TLS termination
- an access key for accessing S3
- AWS Aurora RDS with one reader and writer instance.

## Pre-requisites

This test assumes the following resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate
- a TFE license on a filepath accessible by tests
