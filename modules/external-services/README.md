## Terraform Enterprise External Services

This module provides basic AWS external service resources in the form of:

* An S3 bucket
* An IAM user that can access the S3 bucket
* An Aurora cluster with a single instance in Postgresql mode

This module assumes basic setup with reasonable defaults. If need extensive changes,
best to copy this module and make your own local changes to it.
