# EXAMPLE: Active-Active, External Services Installation of Terraform Enterprise

## About This Example

This example for Terraform Enterprise creates a TFE installation with the following traits:

- Active/Active architecture
- External Services production type
- m5.xlarge virtual machine type
- RHEL 7.9
- A privately accessible TCP load balancer with TLS pass-through
- An ubuntu based mitm proxy server with TLS termination 

## Prerequisites

This example assumes that the following resources exist:

- TFE license is on a file path defined by `var.license_file` 
- A DNS zone
- Valid managed SSL certificate to use with load balancer:
  - Create/Import a managed SSL Certificate using AWS ACM to serve as the certificate for the DNS A Record.
- A valid CA certificate and private key for the MITM proxy that are both stored in the Secrets Manager as secrets. These should be Base64 encoded versions of a PEM encoded certificate and private key.

## How to Use This Module

### Deployment

1. Read the entire [README.md](../../README.md) of the root module.
2. Ensure account meets module prerequisites from above.
3. Clone repository.
4. Change directory into desired example folder.
5. Create a local `terraform.auto.tfvars` file and instantiate the required inputs as required in the respective `./examples/active-active/variables.tf` including the path to the license under the `license_file` variable value.
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

### Connecting to proxy server

1. To create a tunnel for Chrome:
   By default, Chrome uses your macOS or Windows proxy. To change your proxy settings from within Chrome, take the following steps: 
   - Open the Chrome toolbar and select "Settings".
   - Scroll down to the bottom of the display. Click on "Show advanced settings".
   - Scroll down to “System” and choose "Open your computer’s proxy settings".
   - Set Chrome proxy server settings.
2. Next, follow the instructions for your operating system to set up your proxy server settings:
   - [macOS](https://support.apple.com/en-ca/guide/mac-help/mchlp2591/mac)
   - [Windows](https://www.dummies.com/article/technology/computers/operating-systems/windows/windows-10/how-to-set-up-a-proxy-in-windows-10-140262/#tab2)
3. SSH to proxy via: `$ ssh -N -p 22 -D localhost:5000 <proxyuser>@<proxyserver> -i ../path/to/id_rsa`
4. The TFE URL is now aacessible via proxy.

### Connecting to the TFE Application

1. Navigate to the URL supplied via the `login_url` Terraform output. (It may take several minutes for this to be available after initial deployment. You may monitor the progress of cloud init if desired on one of the instances.)
2. Enter a `username`, `email`, and `password` for the initial user.
3. Click `Create an account`.
4. After the initial user is created you may access the TFE Application normally using the URL supplied via `login_url` Terraform output.
