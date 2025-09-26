# TFE Init Module (Replicated)

This module is used to create the script that will install Terraform Enterprise (TFE) via Replicated on a virtual machine.

## Required variables

* `tfe_license_secret_id` - string value for the TFE license secret ID
* `replicated_configuration` - output object from the [`settings` module](../settings) of the Replicated configuration
* `tfe_configuration` - output object from the [`settings` module](../settings) of the TFE configuration

## Example usage

This example illustrates how it may be used by a Terraform Enterprise module, consuming outputs from other submodules.

```hcl
module "tfe_init_replicated" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/tfe_init?ref=main"

  # Replicated Configuration data
  enable_active_active = true

  tfe_configuration           = module.settings.tfe_configuration
  replicated_configuration    = module.settings.replicated_configuration

  # Secrets
  ca_certificate_secret_id = var.ca_certificate_secret_id
  certificate_secret_id    = var.vm_certificate_secret_id
  key_secret_id            = var.vm_key_secret_id
  tfe_license_secret_id    = var.tfe_license_secret_id
}
```

## Resources

This module does not create any Terraform resources, but rather uses the [`templatefile` function](https://www.terraform.io/language/functions/templatefile)
to render a template of the Terraform Enterprise installation script. The module will then output the
rendered script so that it can be used in a TFE installation.
