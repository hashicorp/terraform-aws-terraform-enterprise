data "terraform_remote_state" "vpc" {
  ## backend = "local"  ##  ## config {  ##     path = "${path.module}/../../base-vpc/terraform.tfstate"  ## }

  backend = "atlas"

  config {
    address = "https://tfe.hashicorp.engineering"
    name    = "ptfe/test-scenarios-base-vpc"
  }
}
