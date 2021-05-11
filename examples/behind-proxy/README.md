# EXAMPLE: Deploying Terraform Enterprise behind a proxy

## About This Example

This example functions as a reference for how to use this module to install Terraform Enterprise in an existing VPC using your own proxy.

## Module Prerequisites

As with the main version of this module, this example assumes the following resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate

When deploying in an existing VPC, the `networking` submodule will not be used. Therefore when deploying, the existing VPC must have:

- Public and private subnets
- Nat gateway and appropriate rules
- Routing table and appropriate rules

## How to Use This Module

- Ensure account meets module pre-requisites from above.

- Create a Terraform configuration that pulls in this module and specifies values
  of the required variables:

```hcl
provider "aws" {
  region = "<your AWS region>"
}

module "espd-tfe-aws" {
  source = "../espd-tfe-aws/"

  deploy_vpc                 = false
  domain_name                = "<valid domain name>"
  friendly_name_prefix       = "<prefix used to identify resources created>"
  tfe_license_filepath       = "<filepath to .rli file>"
  network_id                 = "<VPC id for VPC to deploy in>"
  network_private_subnets    = "<private subnets in VPC>"
  network_public_subnets     = "<public subnets in VPC>"
  proxy_ip                   = "<IP address of existing web proxy>"
  proxy_cert_bundle_filepath = "<filepath for proxy cert bundle to copy to S3>"
  proxy_cert_bundle_name     = "<name for proxy cert bundle in S3>"
}
```

- Run `terraform init` and `terraform apply`
