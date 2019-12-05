module "lb" {
  source = "./modules/lb"

  vpc_id     = module.common.vpc_id
  install_id = module.common.install_id

  prefix = var.prefix
  domain = var.domain

  public_subnets              = module.common.public_subnets
  public_subnets_cidr_blocks  = module.common.public_subnets_cidr_blocks
  private_subnets_cidr_blocks = module.common.private_subnets_cidr_blocks

  hostname       = var.hostname
  update_route53 = var.update_route53

  cert_domain = var.cert_domain
  cert_arn    = var.cert_arn
}

