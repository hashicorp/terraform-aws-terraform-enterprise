terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.72"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.18.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.1"
    }
  }
}
