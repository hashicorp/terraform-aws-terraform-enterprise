locals {
  vpc_id         = "vpc-aabbccddeeffgghhiijj"
  tag            = "tfe"
  setup_bucket   = "mycompany-tfe-setup"
  domain         = "mycompany-internal.net"
  hostname       = "tfe"
  license_file   = "mylicense.rli"
  airgap_package = "v201911-1.airgap"
  region         = "us-west-2"
}

provider "aws" {
  region = local.region
}

module "external" {
  source  = "hashicorp/terraform-enterprise/aws/modules/external-services"
  version = "0.1.0"

  vpc_id     = local.vpc_id
  install_id = module.terraform-enterprise.install_id

  rds_subnet_tags = {
    "Usage" = local.tag
  }
}

data "aws_iam_policy_document" "setup-bucket" {
  # TFE Admin settings > Object Storage > S3 Configuration's 'Test Authentication' test calls ListBuckets
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${local.setup_bucket}",
      "arn:aws:s3:::${local.setup_bucket}/*",
    ]
  }
}

resource "aws_iam_role_policy" "setup-bucket" {
  role   = module.terraform-enterprise.iam_role
  name   = "${local.setup_bucket}-${module.terraform-enterprise.install_id}"
  policy = data.aws_iam_policy_document.setup-bucket.json
}

module "terraform-enterprise" {
  source  = "hashicorp/terraform-enterprise/aws"
  version = "0.1.0"

  vpc_id = local.vpc_id
  domain = local.domain

  subnet_tags = {
    "Usage" = local.tag
  }

  license_file    = local.license_file
  primary_count   = 3
  secondary_count = 5
  hostname        = local.hostname
  distribution    = "ubuntu"

  # The data at ptfe.zip at the normal location has been uploaded to a private bucket to be used
  installer_url = "https://${local.setup_bucket}.s3-${local.region}.amazonaws.com/tfe-setup/ptfe.zip"

  # The airgap installer tar.gz is also within the setup bucket
  airgap_installer_url = "s3://${local.setup_bucket}/tfe-setup/replicated.tar.gz?region=${local.region}"

  # The airgap package is located within a bucket that the instances can access.
  airgap_package_url = "s3://${local.setup_bucket}/tfe-setup/${local.airgap_package}?region=${local.region}"

  postgresql_user         = module.external.database_username
  postgresql_password     = module.external.database_password
  postgresql_address      = module.external.database_endpoint
  postgresql_database     = module.external.database_name
  postgresql_extra_params = "sslmode=disable"

  s3_bucket = module.external.s3_bucket
  s3_region = local.region

  aws_access_key_id     = module.external.iam_access_key
  aws_secret_access_key = module.external.iam_secret_key
}

output "primary_public_ip" {
  value = module.terraform-enterprise.primary_public_ip
}

output "installer_dashboard_password" {
  value = module.terraform-enterprise.installer_dashboard_password
}

output "endpoint" {
  value = module.terraform-enterprise.application_endpoint
}
