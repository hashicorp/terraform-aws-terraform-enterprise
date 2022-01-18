# FIXTURE: TFE Secrets Module

This module creates the AWS Secret Manager secrets that are
required by the root TFE module and test modules.

Secrets will only be created if their associated variables have
non-null values.