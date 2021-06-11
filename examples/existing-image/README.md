# EXAMPLE: Deploying Terraform Enterprise in Active/Active mode with a custom image

## About This Example

This example functions as a reference for how to use this module to install 
Terraform Enterprise with a custom image (AMI) in AWS.

## Module Prerequisites

As with the main version of this module, this example assumes the following
resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate
- Valid TFE license

## How to Use This Module

Refer to the root module's instructions for [setup instructions](../../README.md#How-to-Use-This-Module).

- Any variables not defined in this example will use the default values of the
root module, which defaults to a node count of 2, creating an Active/Active configuration.
- Ensure account meets module pre-requisites from above.
- Create a Terraform configuration that pulls in this module and specifies values
  of the required variables (you may do this in a `terraform.tfvars` file):

```hcl
locals {
  ami_search = var.ami_id == null ? true : false
  ami_id     = local.ami_search ? data.aws_ami.existing[0].id : var.ami_id
}

data "aws_ami" "existing" {
  count = local.ami_search ? 1 : 0

  owners      = var.ami_owners
  most_recent = var.ami_most_recent

  filter {
    name   = var.ami_filter_name
    values = [var.ami_filter_value]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "existing_image_example" {
  source = "../../"

  acm_certificate_arn  = var.acm_certificate_arn
  domain_name          = var.domain_name
  friendly_name_prefix = var.friendly_name_prefix
  tfe_subdomain        = var.tfe_subdomain
  tfe_license_name     = var.tfe_license_name
  tfe_license_filepath = var.tfe_license_filepath

  ami_id                = local.ami_id
  iact_subnet_list      = var.iact_subnet_list
  load_balancing_scheme = var.load_balancing_scheme
}
```

With authentication configured, run `terraform init` and `terraform apply` to provision
the example infrastructure.


## Variable Input

The variable inputs described in this document serve as a reference configuration for this specific example. The root module provides many other optional variable inputs.

### Inputs For This Example

| Name | Description | Type | Example Value |
|------|-------------|------| ------------- |
| `acm_certificate_arn` | ACM certificate ARN to use with load balancer | string | `arn:aws:acm:us-east-2:123456:certificate/123abc`
| `domain_name` | Name of existing DNS Zone in which a record set will be created | string | `example.com` |
| `friendly_name_prefix` | Name prefix used for resources | string | `somename` |
| `tfe_subdomain` | Desired DNS record subdomain | string | `tfe` |
| `tfe_license_name` | The name to use when copying the TFE license file to the EC2 instance. | string | `license.rli` |
| `tfe_license_filepath` | The absolute path to the TFE license file on the system running Terraform. | string | `Users/yourname/license.rli` |
| `iact_subnet_list` | A list of CIDR masks that configure the ability to retrieve the IACT from outside the host. | list(string) | `["0.0.0.0/0"]` |
| `load_balancing_scheme` | Load Balancing Scheme. Supported values are: "PRIVATE"; "PRIVATE_TCP"; "PUBLIC". | string | `PUBLIC` |
| `ami_id` | AMI ID of the custom image to use for TFE instances. If this value is provided, you do not need any of the following ami variable values. | string | `ami-12345` |
| `ami_owners` | List of AMI owners to limit search. (Not needed if providing ami_id value.) | list(string) | `["self"]` |
| `ami_filter_name` | The name of a key off of which to filter with a key/value pair. (Not needed if providing ami_id value.) | string | `"tag:Distro"` |
| `ami_filter_value` | The value off of which to filter with a key/value pair. (Not needed if providing ami_id value.) | string | `"Ubuntu"` |
| `ami_most_recent` | If more than one result is returned, use the most recent AMI. (Not needed if providing ami_id value.) | bool | `true` |

### ami_id

The base image used for the custom image should be Ubuntu or RHEL to work with the root
module as-is.

This example will either use the `ami_id` directly, or you may use a data source to filter
on the specific AMI to use.

In the `ami_id` data source, you will notice that this example filters on three criteria, a
unique key/value pair, the virtualization type, and whether or not to use the latest image
in which this search results. Because it is important that Terraform is only able to find
one AMI based on the search of this [data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami),
you may decide to add more filters in order to narrow down your search.

Otherwise, you may decide to provide the `ami_id` variable directly, instead of using the
data source. To do this, simply provide a value for the `ami_id` variable with the specific
AMI ID that you wish to use. If you choose to do this, you do not need to provide values for
the other variables that begin with `ami_`.
