# Terraform Enterprise AWS Module

**IMPORTANT**: You are viewing a **beta version** of the official module to install Terraform Enterprise. This new version is **incompatible with earlier versions**, and it is not currently meant for production use. Please contact your Customer Success Manager for details before using.

This is a Terraform module for provisioning a Terraform Enterprise Cluster on AWS. Terraform Enterprise is our self-hosted distribution of Terraform Cloud. It offers enterprises a private instance of the Terraform Cloud application, with no resource limits and with additional enterprise-grade architectural features like audit logging and SAML single sign-on.

## About This Module

This module will install Terraform Enterprise on AWS according to the [HashiCorp Reference Architecture](https://www.terraform.io/docs/enterprise/before-installing/reference-architecture/aws.html). This module is intended to be used by practitioners seeking a Terraform Enterprise installation which requires minimal configuration in the AWS cloud.

As the goal for this main module is to provide a drop-in solution for installing Terraform Enterprise via the Golden Path, it leverages AWS native solutions such as Route 53 and a vanilla AWS-supplied base AMI. We have provided guidance and limited examples for other use cases.

## Pre-requisites

This module is intended to run in an AWS account with minimal preparation, however it does have the following pre-requisites:

### Terraform version >= 0.14

This module requires Terraform version `0.14` or greater to be installed on the running machine.

### Credentials / Permissions

#### AWS Services Used

- AWS Identity & Access Management (IAM)
- AWS Key Management System (KMS)
- Amazon RDS (Postgres)
- Amazon EC2
- Amazon Elastic Loadbalancing (ALB)
- Amazon Certificate Manager (ACM)
- Amazon Route53
- Amazon Elasticache (Redis)
- Amazon VPC
- Amazon S3
- [OPTIONAL] Amazon Secrets Manager

### Public Hosted Zone

If you are managing DNS via AWS Route53 the hosted zone entry is created automatically as part of your domain management.

If you're managing DNS outside of Route53, please see the documentation on [creating a hosted zone for a subdomain](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-routing-traffic-for-subdomains.html), which you will need to do for the subdomain you are planning to use for your Terraform Enterprise installation. To create this hosted zone with Terraform, use [the `aws_route53_zone` resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone).

### ACM Certificate

Certificate validation can take up two hours, causing timeouts during module apply if the cert is generated as one of the resources contained in the module. For that reason, once the hosted zone has been created, the certificate must be created or imported into ACM. To create or import manually, see the [AWS ACM certificate documentation](https://docs.aws.amazon.com/acm/latest/userguide/gs.html). To create or manage certificates with Terraform, we recommend the [official ACM module in the Terraform Registry](https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest).

**Note:** This module has been tested in the following AWS regions:

- `us-east-1`
- `eu-west-1`
- `eu-west-2`

## How to Use This Module

- Ensure account meets module pre-requisites from above.
- You may also choose to use this module with a custom AMI image as shown in the [`existing-image`](./examples/existing-image) example.
- Please note that while some resources are individually and uniquely tagged, all common tags are expected to be configured within the AWS provider as shown in the example code snippet below.

- Create a Terraform configuration that pulls in this module and specifies values
  of the required variables:

```hcl
provider "aws" {
  region = "<your AWS region>"
  default_tags {
    tags = var.common_tags
  }
}

module "tfe_node" {
  source                 = "<filepath to cloned module directory>"
  friendly_name_prefix   = "<prefix for naming AWS resources>"
  domain_name            = "<domain for creating the Terraform Enterprise subdomain on. >"
  tfe_license_secret_id  = data.aws_secretsmanager_secret_version.tfe_license.secret_id
  acm_certificate_arn    = "<ARN for ACM cert to be used with load balancer>"
}
```

- Run `terraform init` and `terraform apply`

## Access to the Application Servers

- Cloud-native access to application servers which lie behind load-balancers is recommended over SSH/bastion-based access.
- This module deploys the SSM agent on RHEL (it is already present in the Ubuntu AWS marketplace images), but requires an IAM role policy ARN such as "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" in the `iam_role_policy_arns` list in order to enable access via SSM. Your options at this time are:
  - Deploy the requisite IAM role policy.
  - Add additional resources to deploy a bastion host as required to be able to access the application hosts on the command line.

## Module Manifest

This module will create all infrastructure resources required to install Terraform Enterprise in a standalone or active-active configuration (depending on how many nodes you specify) on AWS in the designated region according to the Reference Architecture. The default base AMI used is Ubuntu 20.04 LTS but you may specify a RHEL 7.x AMI ID by using the `ami_id` variable.

The resources created are:

- VPC with public and private subnets
- PostgreSQL instance
- Redis cache
- S3 bucket for installation bootstrapping
- Auto-scaling group behind Application Load Balancer (ALB)
- Secrets Manager Secret used for deploys
- KMS key
- IAM Instance Role and IAM Policy to allow instances to retrieve bootstrap secrets
- Route53 A Record for Load Balancer on TFE domain
- Supporting security groups and rules for application functionality

## Examples

We have included documentation and reference examples for additional common installation scenarios for TFE, as well as examples for supporting resources that lack official modules.

- [Example: Deploying with an existing, custom image](./examples/existing-image)
- [Example: Deploying with AWS Aurora RDS cluster instance](./examples/standalone-aurora)
- [Example: Deploying behind a proxy (coming soon...)](./examples/behind-proxy)
- [Example: Deploying into an existing private network (coming soon...)](./examples/existing-private-network)
- [Example: Deploying while managing DNS outside of AWS (coming soon...)](./examples/external-dns)

## License

This code is released under the Mozilla Public License 2.0. Please see [LICENSE](https://github.com/hashicorp/terraform-aws-terraform-enterprise/blob/main/LICENSE)
for more details.
