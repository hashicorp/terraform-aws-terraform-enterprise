# Terraform Test

The directories in here are considered Terraform Test Modules (TTM). These TTM
directories are used in our continuous integration process using GitHub Actions.

These tests also leverage Terraform Cloud workspaces to allow
maintainers to run and audit contributions to this repository.

## Tools and commands

These commands will be run on Pull Requests automatically:

- `terraform fmt`
- `tflint`

These commands will be run by Maintainers manually after initial review:

- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform apply`
- `k6`
- `terraform destroy`
