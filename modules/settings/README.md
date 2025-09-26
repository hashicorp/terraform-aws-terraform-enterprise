# TFE Settings Module

This module is used to create the settings that are required for installing Terraform Enterprise (TFE) on a virtual machine.

## Required variables

None of the variables in this module are required, however, if you are using this module to provide the input
variables for the [`tfe_init`](../tfe_init) module, then please review both the variables file in this module
as well as the `tfe_init` module to see what you will need.

## Example usage

This example illustrates how this module may be used by a Terraform Enterprise module, consuming outputs from other submodules.

```hcl
module "settings" {
  source = "git::https://github.com/hashicorp/terraform-random-tfe-utility//modules/settings?ref=main"

  # TFE Base Configuration
  production_type   = var.production_type
  iact_subnet_list  = var.iact_subnet_list
  trusted_proxies   = local.trusted_proxies
  release_sequence  = var.release_sequence
  pg_extra_params   = var.pg_extra_params

  # Replicated Base Configuration
  hostname                    = module.load_balancer.fqdn
  tfe_license_file_location   = var.tfe_license_file_location
  tls_bootstrap_cert_pathname = var.tls_bootstrap_cert_pathname
  tls_bootstrap_key_pathname  = var.tls_bootstrap_key_pathname
  bypass_preflight_checks     = var.bypass_preflight_checks

  # Database
  pg_dbname   = local.database.name
  pg_netloc   = local.database.address
  pg_user     = local.database.server.administrator_login
  pg_password = local.database.server.administrator_password

  # Redis
  redis_host                = local.redis.host
  redis_pass                = local.redis.pass
  redis_use_tls             = local.redis.use_tls
  redis_use_password_auth   = local.redis.use_password_auth

  # Azure
  azure_account_key  = local.object_storage.storage_account_key
  azure_account_name = local.object_storage.storage_account_name
  azure_container    = local.object_storage.storage_account_container_name
}
```

## Resources

- [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)

In addition to `random_id` resources, this module uses `local` variables to form objects that will
be output with the intention of becoming input variables for the [`tfe_init`](../tfe_init) module.
