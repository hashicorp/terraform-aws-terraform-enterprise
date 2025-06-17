# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = ">= 0.14"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    doormat = {
      source  = "doormat.hashicorp.services/hashicorp-security/doormat"
      version = "0.0.7"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "~> 1.2.2"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.90.0"
    }
    jq = {
      source  = "massdriver-cloud/jq"
      version = "~> 0.2.0"
    }
  }
}
