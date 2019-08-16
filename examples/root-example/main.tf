provider "aws" {
  region = "us-west-2"
}

module "tfe-ha" {
  source = "github.com/hashicorp/terraform-aws-tfe-ha"

  version = "0.1.0"
  vpc_id          = "vpc-123456789abcd1234"
  domain          = "example.com"
  license_file    = "company.rli"
  secondary_count = "3"
  primary_count   = "3"
  distribution    = "ubuntu"
}
