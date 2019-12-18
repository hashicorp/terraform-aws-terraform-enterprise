module "common" {
  source             = "./modules/common-user-vpc"
  vpc_id             = var.vpc_id
  subnet_tags        = var.subnet_tags
  ingress_allow_list = var.ingress_allow_list
  prefix             = var.prefix
}

