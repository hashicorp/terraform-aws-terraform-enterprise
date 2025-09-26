# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  database = {
    TFE_DATABASE_USER                         = var.database_user
    TFE_DATABASE_PASSWORD                     = var.database_password
    TFE_DATABASE_HOST                         = var.database_host
    TFE_DATABASE_NAME                         = var.database_name
    TFE_DATABASE_PARAMETERS                   = var.database_parameters
    TFE_DATABASE_USE_MTLS                     = var.database_use_mtls
    TFE_DATABASE_CA_CERT_FILE                 = var.database_ca_cert_file
    TFE_DATABASE_CLIENT_CERT_FILE             = var.database_client_cert_file
    TFE_DATABASE_CLIENT_KEY_FILE              = var.database_client_key_file
    TFE_DATABASE_PASSWORDLESS_AZURE_USE_MSI   = var.database_passwordless_azure_use_msi
    TFE_DATABASE_PASSWORDLESS_AZURE_CLIENT_ID = var.database_passwordless_azure_client_id
    DATABASE_AUTH_USE_AWS_IAM                 = var.database_passwordless_aws_use_iam
    DATABASE_AUTH_AWS_DB_REGION               = var.database_passwordless_aws_region
  }
  database_configuration = local.disk ? {} : local.database
  explorer_database = {
    TFE_EXPLORER_DATABASE_HOST       = var.explorer_database_host
    TFE_EXPLORER_DATABASE_NAME       = var.explorer_database_name
    TFE_EXPLORER_DATABASE_USER       = var.explorer_database_user
    TFE_EXPLORER_DATABASE_PASSWORD   = var.explorer_database_password
    TFE_EXPLORER_DATABASE_PARAMETERS = var.explorer_database_parameters
  }
  explorer_database_configuration = var.explorer_database_host == null ? {} : local.explorer_database
}
