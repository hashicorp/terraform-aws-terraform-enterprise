# EXAMPLE: Using this module to deploy in an existing private network

## About This Example

This example functions as a reference for how to use this module to install Terraform Enterprise in an existing VPC on AWS.

## Module Prerequisites

As with the main version of this module, this example assumes the following resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate

When deploying in an existing VPC, the `networking` submodule will not
be used. Therefore when deploying, the existing VPC must have:

- Public and private subnets
- Nat gateway and appropriate rules
- Routing table and appropriate rules

## How to Use This Module

- Ensure account meets module pre-requisites from above.

- Create a Terraform configuration that pulls in this module and specifies values
  of the required variables:

```hcl
provider "aws" {
  region      = "<your AWS region>"
}

module "espd-tfe-aws" {
  source = "../espd-tfe-aws/"

  deploy_vpc              = false
  domain_name             = "<valid domain name>"
  friendly_name_prefix    = "<prefix used to identify resources created>"
  tfe_license_filepath    = "<filepath to .rli file>"
  network_id              = "<VPC id for VPC to deploy in>"
  network_private_subnets = "<private subnets in VPC>"
  network_public_subnets  = "<public subnets in VPC>"
}
```

- _OPTIONAL_: This module can be deployed with a custom AMI rather than the default base given (Ubuntu 20.04 LTS), and has been verified to be functional with Ubuntu 20.04 LTS and RHEL 7.x based images. To deploy using a custom image, use the following configuration instead:

```hcl
provider "aws" {
  region = "<your AWS region>"
}

module "espd-tfe-aws" {
  source = "../espd-tfe-aws/"

  ami_id                  = "<id for custom AMI>"
  deploy_vpc              = false
  domain_name             = "<valid domain name>"
  friendly_name_prefix    = "<prefix used to identify resources created>"
  tfe_license_filepath    = "<filepath to .rli file>"
  network_id              = "<VPC id for VPC to deploy in>"
  network_private_subnets = "<private subnets in VPC>"
  network_public_subnets  = "<public subnets in VPC>"
}
```

- Run `terraform init` and `terraform apply`
