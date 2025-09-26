# postgres-passwordless Module

This module provisions a PostgreSQL instance with passwordless authentication on an EC2 instance for use with Terraform Enterprise. This module follows the same pattern as the `database-mtls` module but without certificate handling.

## Features
- EC2-based PostgreSQL deployment with Docker
- Security group configuration for PostgreSQL access
- Route53 DNS record for easy access
- Random password generation (for admin setup)
- SSH key pair generation for EC2 access
- Automated PostgreSQL setup via user data script

## Usage Example
```hcl
module "postgres_passwordless" {
  source                  = "./modules/postgres-passwordless"
  domain_name             = "example.com"
  db_name                 = "tfe"
  db_username             = "tfeadmin"
  network_id              = var.vpc_id
  network_public_subnets  = var.public_subnet_ids
  friendly_name_prefix    = "tfe"
  aws_iam_instance_profile = var.iam_instance_profile
}
```

## Variables
- `domain_name`: Route 53 hosted zone name for DNS record
- `db_name`: PostgreSQL database name
- `db_username`: PostgreSQL username
- `network_id`: VPC ID for security group
- `network_public_subnets`: List of public subnet IDs
- `friendly_name_prefix`: Prefix for resource names
- `aws_iam_instance_profile`: IAM instance profile for the EC2 instance

## Outputs
- `postgres_db_endpoint`: The FQDN of the PostgreSQL instance
- `postgres_db_sg_id`: The security group ID for the PostgreSQL instance
- `postgres_db_password`: The password for the PostgreSQL instance (sensitive)

## Files Structure
- `main.tf`: Main Terraform configuration
- `variables.tf`: Variable definitions
- `outputs.tf`: Output definitions
- `data.tf`: Data source definitions
- `versions.tf`: Provider version constraints
- `files/fetch_cert_and_start_server.sh`: Script to set up PostgreSQL on EC2

## Notes
- This module creates an EC2 instance running PostgreSQL in Docker
- The instance is configured for passwordless authentication patterns
- A Route53 DNS record is created for easy access
- SSH access is configured for troubleshooting
