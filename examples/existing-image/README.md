# EXAMPLE: Using this module to deploy with a custom image

## About This Example

This example functions as a reference for how to use this module to install Terraform Enterprise with a custom image (AMI) in AWS. This module has been verified to be functional with Ubuntu 20.04 LTS and RHEL 7.x based images.

## Module Prerequisites

As with the main version of this module, this example assumes the following resources already exist:

- Valid DNS Zone managed in Route53
- Valid AWS ACM certificate
- Valid TFE license

## How to Use This Module

- Ensure account meets module pre-requisites from above.
- Create a Terraform configuration that pulls in this module and specifies values
  of the required variables (you may do this in a `terraform.tfvars` file):

```hcl
provider "aws" {}

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

  ami_id                = data.aws_ami.existing.id
  iact_subnet_list      = var.iact_subnet_list
  load_balancing_scheme = var.load_balancing_scheme

  common_tags = var.common_tags
}
```

- Run `terraform init` and `terraform apply`

### ami_id

This example will either use the `ami_id` directly, or you may use a data source to filter on the specific AMI to use.

In the `ami_id` data source, you will notice that this example filters on three criteria, a unique key/value pair, the virtualization type, and whether or not to use the latest image in which this search results. Because it is important that Terraform is only able to find one AMI based on the search of this [data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami), you may decide to add more filters in order to narrow down your search.

Otherwise, you may decide to provide the `ami_id` variable directly, instead of using the data source. To do this, simply provide a value for the `ami_id` variable with the specific AMI ID that you wish to use. If you choose to do this, you do not need to provide values for the other variables that begin with `ami_`.