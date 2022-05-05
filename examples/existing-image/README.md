# EXAMPLE: Active-Active, External Services Installation of Terraform Enterprise with a Custom Image

## About This Example

This example for Terraform Enterprise creates a TFE installation with the following traits:

-  [Active/Active](https://www.terraform.io/enterprise/install/automated/active-active) architecture defined by `var.node_count`
-  External Services production type
-  m5.xlarge virtual machine type
-  Ubuntu 20.04
-  A publicly accessible HTTP load balancer with TLS termination

## Prerequisites

This example assumes that the following resources exist:

- TFE license is on a file path defined by `var.license_file` 
- A DNS zone
- Valid managed SSL certificate to use with load balancer:
  - Create/Import a managed SSL Certificate using AWS ACM to serve as the certificate for the DNS A Record.
- Existing Amazon Machine Image defined by `var.ami_id`

  NOTE: The base image used for the custom image should be Ubuntu or RHEL to work with the root
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
  
## How to Use This Module

### Deployment

 1. Read the entire [README.md](../../README.md) of the root module.
 2. Ensure account meets module prerequisites from above.
 3. Clone repository.
 4. Change directory into desired example folder.
 5. Create a local `terraform.auto.tfvars` file and instantiate the required inputs as required in the respective `./examples/existing-image/variables.tf` including the path to the license under the `license_file` variable value.
 6. Authenticate against the AWS provider. See [instructions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).
 7. Initialize terraform and apply the module configurations using the commands below:

    NOTE: `terraform plan` will print out the execution plan which describes the actions Terraform will take in order to build your infrastructure to match the module configuration. If anything in the plan seems incorrect or dangerous, it is safe to abort here and not proceed to `terraform apply`.

    ```
    terraform init
    terraform plan
    terraform apply
    ```

## Post-deployment Tasks

The build should take approximately 10-15 minutes to deploy. Once the module has completed, give the platform another 10 minutes or so prior to attempting to interact with it in order for all containers to start up.

Unless amended, this example will not create an initial admin user using the IACT, but it does output the URL for your convenience. Follow the advice in this document to create the initial admin user, and log into the system using this user in order to configure it for use.

### Connecting to the TFE Application

1. Navigate to the URL supplied via the `login_url` Terraform output. (It may take several minutes for this to be available after initial deployment. You may monitor the progress of cloud init if desired on one of the instances)
2. Enter a `username`, `email`, and `password` for the initial user.
3. Click `Create an account`.
4. After the initial user is created you may access the TFE Application normally using the URL supplied via `login_url` Terraform output.