output "install_id" {
  value = "${random_string.install_id.result}"
}

output "vpc_id" {
  value = "${data.terraform_remote_state.vpc.vpc_id}"
}

output "availability_zones" {
  value = "${data.terraform_remote_state.vpc.availability_zones}"
}

output "ssh_priv_key_file" {
  value = "${local.private_key_filename}"
}

output "ssh_key_name" {
  value = "${local.key_name}"
}

output "public_subnets" {
  value = "${data.terraform_remote_state.vpc.public_subnets}"
}

output "private_subnets" {
  value = "${data.terraform_remote_state.vpc.private_subnets}"
}

output "private_subnets_cidr_blocks" {
  value = "${data.terraform_remote_state.vpc.private_subnets_cidr_blocks}"
}

output "public_subnets_cidr_blocks" {
  value = "${data.terraform_remote_state.vpc.public_subnets_cidr_blocks}"
}

output "database_subnet_group" {
  value = "${data.terraform_remote_state.vpc.database_subnet_group}"
}

output "intra_vpc_and_egress_sg_id" {
  value = "${data.terraform_remote_state.vpc.intra_vpc_and_egress_sg_id}"
}

output "allow_ptfe_sg_id" {
  value = "${data.terraform_remote_state.vpc.allow_ptfe_sg_id}"
}

output "domain" {
  value = "${data.terraform_remote_state.vpc.domain}"
}

output "collect_diag_file" {
  value = "${path.module}/../common/files/collect-diag.sh" ## I am lazy
}
