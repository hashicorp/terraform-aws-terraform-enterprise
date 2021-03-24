# EXAMPLE: Deploying Terraform Enterprise Persona as Startup

## About this example

This example functions as a reference for how to use this module to install
Terraform Enterprise as a Startup Persona.

Traits of the Startup persona include:

- Active/Active mode
- a small VM machine type (m5.xlarge)
- Ubuntu 20.04 as the VM image
- a publicly accessible HTTP load balancer with TLS termination
- no proxy server
- no Redis authentication
- no Redis encryption in transit

## Module pre-requisites

As with the main version of this module, this example assumes the following
resources already exist:

* Valid DNS Zone managed in Route53
* Valid AWS ACM certificate

When deploying in an existing VPC the `bastion` and `networking` submodules will
not be used. Therefore when deploying, the existing VPC must have:

* Public and private subnets
* NAT gateway and appropriate rules
* Routing table and appropriate rules

## How to use this module

* Ensure account meets module pre-requisites from above.
* Create a Terraform configuration that pulls in this module and specifies
    values of the required variables:

```hcl
domain_name          = "<DOMAIN_NAME>"
license_path         = "<PATH_TO_LOCAL_LICENSE>"
acm_certificate_arn  = "<EXISTING_ACM_CERTIFICATE_ARM>"

# Leverages an AWS Key Pair for the accessing the Bastion instance
bastion_keypair = "rruiz-testing"

# Creates a public load balancer
load_balancing_scheme = "PUBLIC"
```

With the configuration created, run `terraform init` and `terraform apply` to provision the example infrastructure.
