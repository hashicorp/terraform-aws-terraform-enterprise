terraform {
  backend "remote" {
    organization = "terraform-enterprise-modules-test"

    workspaces {
      name = "aws-public-active-active"
    }
  }
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
