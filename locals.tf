locals {
  active_active                = var.node_count >= 2
  ami_id                       = local.default_ami_id ? data.aws_ami.ubuntu.id : var.ami_id
  default_ami_id               = var.ami_id == ""
  fqdn                         = "${var.tfe_subdomain}.${var.domain_name}"
  iam_principal                = { arn = try(var.object_storage_iam_user.arn, module.service_accounts.iam_role.arn) }
  network_id                   = var.deploy_vpc ? module.networking[0].network_id : var.network_id
  network_private_subnets      = var.deploy_vpc ? module.networking[0].network_private_subnets : var.network_private_subnets
  network_public_subnets       = var.deploy_vpc ? module.networking[0].network_public_subnets : var.network_public_subnets
  network_private_subnet_cidrs = var.deploy_vpc ? module.networking[0].network_private_subnet_cidrs : var.network_private_subnet_cidrs
}
