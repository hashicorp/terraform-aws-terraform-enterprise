module "secrets" {
  source = "../../fixtures/secrets"
  tfe_license = {
    name = "my-tfe-license"
    path = var.tfe_license.path
  }
}