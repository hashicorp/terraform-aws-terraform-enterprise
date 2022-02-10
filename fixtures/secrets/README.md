# FIXTURE: TFE Secrets Module

This module creates the AWS Secret Manager secrets that are
required by the root TFE module and test modules.

Secrets will only be created if their associated variables have
non-null values.

## Example usage

```hcl

module "secrets" {
  source = "./fixtures/secrets"
  license_file = var.license_file
}

```

## Resources

- [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)
- [aws_secretsmanager_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)


terraform apply -destroy -var 'acm_certificate_arn=arn:aws:acm:us-east-2:873298400219:certificate/16b5513b-1d6f-47a3-b9a9-59e0f42848fc' -var 'license_file=/Users/sandramariapeter/Desktop/FINAL DEPLOYMENTS/terraform-aws-terraform-enterprise/fixtures/secrets/test.rli' -var 'domain_name=tfe-modules-test.aws.ptfedev.com'