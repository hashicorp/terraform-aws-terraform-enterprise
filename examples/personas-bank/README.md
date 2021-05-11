# EXAMPLE: Deploying Terraform Enterprise Persona as Bank

## About this example

This example functions as a reference for how to use this module to install
Terraform Enterprise as a Bank persona.

Traits of the Bank persona include:

- Active/Active mode
- a large VM machine type (m5.xlarge)
- Red Hat 7.8 as the VM image
- a privately accessible TCP load balancer with TLS pass-through
- a proxy server with TLS termination
- Redis authentication
- Redis encryption in transit

## Module pre-requisites

As with the main version of this module, this example assumes the following
resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate

When deploying in an existing VPC, the `networking` submodule will
not be used. Therefore when deploying, the existing VPC must have:

- Public and private subnets
- NAT gateway and appropriate rules
- Routing table and appropriate rules

## How to use this module

- Ensure account meets module pre-requisites from above.
- Create a Terraform configuration that pulls in this module and specifies
  values of the required variables:

```hcl
provider "aws" {
  region = "<your AWS region>"
}

module "aws_bank_persona" {
  source = "git@github.com:hashicorp/terraform-aws-terraform-enterprise"

  domain_name          = "<DOMAIN_NAME>"
  license_path         = "<PATH_TO_LOCAL_LICENSE>"
  acm_certificate_arn  = "<EXISTING_ACM_CERTIFICATE_ARM>"

  ami_id = "<A_SUPPORTED_RHEL_AMI_ID>"

  proxy_cert_bundle_filepath = "<FILE_PATH_TO_PEM>"
  proxy_cert_bundle_name     = "<NAME_OF_CERT_BUNDLE>"
  proxy_ip                   = "<IP_FOR_PROXY_AND_PORT>"

  load_balancing_scheme = "PRIVATE_TCP"

  # Configure Redis security
  redis_require_password      = true
  redis_encryption_in_transit = true
  redis_encryption_at_rest    = true
}
```

With the configuration created, run `terraform init` and `terraform apply` to provision the example infrastructure.

### Accessing the Private Deployment via Web Browser

An SOCKS5 proxy over an SSH channel on your workstation can be used
to access the TFE deployment from outside of the AWS network. The
following example demonstrates how to establish a SOCKS5 proxy using
Bash, the AWS CLI, jq, ssh, and an Internet browser.

First, establish the SOCKS5 proxy. The following commands create a
proxy listening to port 5000 and bound to localhost which forwards
traffic through one of the compute instances in the TFE delpoyment.
Be sure to change the values in between `< >`:

```bash
group_name=$(terraform output tfe_autoscaling_group_name)
instance_id=$( \
  aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $group_name | \
    jq --raw-output .AutoScalingGroups[0].Instances[0].InstanceId
)
ssh \
  -i <pathname of private key from key pair specified by var.key_name> \
  -o 'ProxyCommand sh -c "\
    aws ssm start-session \
      --target %h \
      --document-name AWS-StartSSHSession \
      --parameters \'portNumber=%p\'"' \
  -N -p 22 -D localhost:5000 \
  ec2-user@$instance_id
```

Second, a web browser or the operating system must be configured to use
the SOCKS5 proxy. The instructions to accomplish this vary depending on
the browser or operating system in use, but in Firefox, this can be
configured in:

> Preferences > Network Settings > Manual proxy configuration >
> SOCKS: Host; Port

Third, the URL from the login_url Terraform output can be accessed
through the browser to start using the deployment. It is expected that
the browser will issue an untrusted certificate warning as this example
attaches a self-signed certificate to the internal load balancer.

### Proxy examples

The proxy in this example is not intended to be a production-grade example of
proxy configurations. The only requirement for this example is to provide a
proxy IP address and optionally a proxy PORT number for setting up TFE to
leverage your proxy. The example in this directory leverages a
development-configured MITM proxy.
