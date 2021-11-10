# TEST: Standalone Vault Terraform Enterprise

## About this test

This test for Terraform Enterprise creates a TFE
installation with the following traits.

- Active/Active mode
- a small VM machine type (m5.xlarge)
- Ubuntu 20.04 as the VM image
- a publicly accessible HTTP load balancer with TLS termination
- no proxy server
- External PostgreSQL
- External Redis
  - no Redis authentication
  - no Redis encryption in transit
- External Vault

## Pre-requisites

This test assumes the following resources exist.

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate
- TFE license on a filepath accessible by tests
- HCP Organization
- HCP HashiCorp Virtual Network

## How this test is used

This test is leveraged by the integration tests in the [`ptfe-replicated`](https://github.com/hashicorp/ptfe-replicated/blob/master/.circleci/config.yml)
repository.

Because the Vault provider is dependent upon output from the HCP resources, we must
create this infrastructure in two stages:

```
$ terraform apply -target=hcp_vault_cluster.test -target=hcp_vault_cluster_admin_token.test

$ terraform apply
```