# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  storage_options = {
    azure = {
      TFE_OBJECT_STORAGE_TYPE               = var.storage_type
      TFE_OBJECT_STORAGE_AZURE_ACCOUNT_KEY  = var.azure_account_key
      TFE_OBJECT_STORAGE_AZURE_ACCOUNT_NAME = var.azure_account_name
      TFE_OBJECT_STORAGE_AZURE_CONTAINER    = var.azure_container
      TFE_OBJECT_STORAGE_AZURE_ENDPOINT     = var.azure_endpoint
    }
    google = {
      TFE_OBJECT_STORAGE_TYPE               = var.storage_type
      TFE_OBJECT_STORAGE_GOOGLE_BUCKET      = var.google_bucket
      TFE_OBJECT_STORAGE_GOOGLE_CREDENTIALS = var.google_credentials
      TFE_OBJECT_STORAGE_GOOGLE_PROJECT     = var.google_project
    }
    s3 = {
      TFE_OBJECT_STORAGE_TYPE                                 = var.storage_type
      TFE_OBJECT_STORAGE_S3_ACCESS_KEY_ID                     = var.s3_access_key_id
      TFE_OBJECT_STORAGE_S3_SECRET_ACCESS_KEY                 = var.s3_secret_access_key
      TFE_OBJECT_STORAGE_S3_REGION                            = var.s3_region
      TFE_OBJECT_STORAGE_S3_BUCKET                            = var.s3_bucket
      TFE_OBJECT_STORAGE_S3_ENDPOINT                          = var.s3_endpoint
      TFE_OBJECT_STORAGE_S3_SERVER_SIDE_ENCRYPTION            = var.s3_server_side_encryption
      TFE_OBJECT_STORAGE_S3_SERVER_SIDE_ENCRYPTION_KMS_KEY_ID = var.s3_server_side_encryption_kms_key_id
      TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE              = var.s3_use_instance_profile
    }
  }

  storage_configuration = var.storage_type != null && !local.disk ? local.storage_options[var.storage_type] : {}
}
