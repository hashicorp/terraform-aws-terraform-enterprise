# TFE Init Module

This module is used to create the script that will install Terraform Enterprise (TFE) with [Flexible Deployments Options](https://developer.hashicorp.com/terraform/enterprise/flexible-deployments) on a virtual machine.

## Required variables

* `cloud` - the cloud you are deploying to; `aws`, `azurerm`, or `google`
* `distribution` - the OS distribution on which TFE will be deployed; `rhel` or `ubuntu`
* `registry_username` - the username for the docker registry from which to pull the terraform_enterprise container images
* `registry_password` - the password for the docker registry from which to pull the terraform_enterprise container images
* `docker_compose_yaml` - the yaml encoded contents of what make up a docker compose file, to be run with docker compose in the user data script
* `operational_mode` - `disk`, `external`, or `active-active`

## Example usage

This example illustrates how it may be used by a Terraform Enterprise module, consuming outputs from other submodules.

```hcl
module "tfe_init_fdo" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/tfe_init?ref=main"

  cloud             = "azurerm"
  distribution      = "ubuntu"
  disk_path         = "/opt/hashicorp/data"
  disk_device_name  = "disk/azure/scsi1/lun${var.vm_data_disk_lun}"
  operational_mode  = "disk"
  enable_monitoring = true

  ca_certificate_secret_id = var.ca_certificate_secret
  certificate_secret_id    = var.vm_certificate_secret
  key_secret_id            = var.vm_key_secret

  registry_username   = "myusername"
  registry_password   = "mypassword"
  docker_compose_yaml = module.docker_compose_config.docker_compose_yaml
}
```

## Resources

This module does not create any Terraform resources, but rather uses the [`templatefile` function](https://www.terraform.io/language/functions/templatefile)
to render a template of the Terraform Enterprise installation script. The module will then output the
rendered script so that it can be used in a TFE installation.
