# EXAMPLE: Deploying Terraform Enterprise Persona as Retailer

## About this example

This example functions as a reference for how to use this module to install
Terraform Enterprise as a Retailer persona.

Traits of the Retailer persona include:

- Active/Active mode
- a medium VM machine type (m5.xlarge)
- Red Hat 7.8 as the VM image
- a privately accessible HTTP load balancer with TLS termination
- a proxy server with TLS pass-through
- Redis authentication
- no Redis encryption in transit

## Module pre-requisites

As with the main version of this module, this example assumes the following
resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate

When deploying in an existing VPC the `bastion` and `networking` submodules will
not be used. Therefore when deploying, the existing VPC must have:

- Public and private subnets
- NAT gateway and appropriate rules
- Routing table and appropriate rules

## How to use this module

- Ensure account meets module pre-requisites from above.
- Create a Terraform configuration that pulls in this module and specifies
    values of the required variables:

```hcl
domain_name          = "<DOMAIN_NAME>"
license_path         = "<PATH_TO_LOCAL_LICENSE>"
acm_certificate_arn  = "<EXISTING_ACM_CERTIFICATE_ARM>"

# Leverages an AWS Key Pair for the accessing the Bastion instance
bastion_keypair = "<AWS_KEYPAIR_NAME>"

ami_id = "<A_SUPPORTED_RHEL_AMI_ID>"

proxy_ip = "<IP_FOR_PROXY_AND_PORT>"

load_balancing_scheme = "PRIVATE"

# Configure Redis security
redis_encryption_in_transit = true
redis_require_password      = true
redis_encryption_at_rest    = false
```

With the configuration created, run `terraform init` and `terraform apply` to provision the example infrastructure.

### Accessing the Private Deployment via Web Browser

An SOCKS5 proxy over an SSH channel on your workstation can be used
to access the TFE deployment from outside of the AWS network. The
following example demonstrates how to establish a SOCKS5 proxy using
Bash, a bastion host virtual machine, and an Internet browser.

First, establish the SOCKS5 proxy. The following command creates a
proxy listening to port 5000 and bound to localhost which forwards
traffic through one of the compute instances in the TFE delpoyment.
Be sure to change the values in between `< >`:

```bash
ssh \
  -N \
  -p 22 \
  -D localhost:5000 \
  -i <pathname of private key for var.existing_keypair> \
  <bastionuser>@<bastion-vm.fqdn.com>
```

Second, a web browser or the operating system must be configured to use
the SOCKS5 proxy. The instructions to accomplish this vary depending on
the browser or operating system in use, but in Firefox, this can be
configured in:

> Preferences > Network Settings > Manual proxy configuration >
SOCKS: Host; Port

Third, the URL from the login_url Terraform output can be accessed
through the browser to start using the deployment. It is expected that
the browser will issue an untrusted certificate warning as this example
attaches a self-signed certificate to the internal load balancer.

### Proxy examples

The proxy in this example is not intended to be a production-grade example of
proxy configurations. The only requirement for this example is to provide a
proxy IP address and optionally a proxy PORT number for setting up TFE to
leverage your proxy. The example in this directory leverages a
development-configured Squid proxy.
