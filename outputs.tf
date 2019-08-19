## this allows the user to do `ssh -F ssh-config default`
resource "local_file" "ssh_config" {
  filename = "${path.module}/work/ssh-config"
  content  = "${data.template_file.ssh_config.rendered}"
}

output "ssh_config_file" {
  value = "${local_file.ssh_config.filename}"
}

output "ssh_private_key" {
  value = "${module.common.ssh_priv_key_file}"
}

output "installer_dashboard_password" {
  value = "${random_pet.console_password.id}"
}

output "installer_dashboard_url" {
  value = "https://${module.lb.endpoint}:8800"
}

output "tfe_endpoint" {
  value = "https://${module.lb.endpoint}"
}

output "tfe_health_check" {
  value = "https://${module.lb.endpoint}/_health_check"
}

output "primary_public_ip" {
  value = "${element(aws_instance.primary.*.public_ip, 0)}"
}

output "lb_endpoint" {
  value = "${module.lb.endpoint}"
}

output "iam_role" {
  value = "${aws_iam_role.ptfe.name}"
}

output "install_id" {
  value = "${module.common.install_id}"
}
