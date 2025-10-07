# service_accounts Module for postgres-passwordless

This module creates IAM roles and instance profiles specifically for the PostgreSQL passwordless authentication setup. It provides the necessary permissions for EC2 instances to authenticate with RDS using IAM authentication.

## Features
- IAM instance profile creation for EC2 instances
- IAM role with RDS IAM authentication permissions
- Basic EC2 and CloudWatch permissions
- Optional KMS permissions for encryption
- Support for existing IAM roles/profiles

## Usage Example
```hcl
module "postgres_passwordless_service_accounts" {
  source = "./modules/postgres-passwordless/service_accounts"
  
  friendly_name_prefix     = "tfe"
  db_instance_identifier   = "tfe-postgres"
  db_username             = "tfeadmin"
  kms_key_arn             = var.kms_key_arn
}
```

## Variables
- `friendly_name_prefix`: Prefix for resource names
- `db_instance_identifier`: RDS instance identifier for IAM auth
- `db_username`: Database username for IAM auth
- `existing_iam_instance_profile_name`: Use existing profile (optional)
- `existing_iam_instance_role_name`: Use existing role (optional)
- `iam_role_policy_arns`: Additional policy ARNs to attach
- `kms_key_arn`: KMS key ARN for encryption (optional)

## Outputs
- `iam_instance_profile`: The IAM instance profile object
- `iam_instance_profile_name`: The name of the IAM instance profile
- `iam_role`: The IAM role object
- `iam_role_name`: The name of the IAM role

## Permissions Included
- `rds-db:connect` for IAM database authentication
- Basic EC2 and CloudWatch permissions
- Optional KMS permissions for encryption
- Support for additional custom policies

## Notes
- This module is specifically designed for passwordless PostgreSQL authentication
- The RDS IAM authentication policy is scoped to the specific database and user
- KMS permissions are only created if a KMS key ARN is provided