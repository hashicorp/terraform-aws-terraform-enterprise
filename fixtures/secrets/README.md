# FIXTURE: TFE Secrets Module

This module creates the AWS Secret Manager secrets that are
required by the root TFE module and test modules.

Secrets will only be created if their associated variables have
non-null values.

## Example usage

```hcl

module "secrets" {
  source = "./fixtures/secrets"

  tfe_license = {
    name = "${var.friendly_name_prefix}-license"
    path = var.license_file
  }
}

```

## Resources

- [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)
- [aws_secretsmanager_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)
