locals {
  app_data_mode    = var.postgresql_address != "" ? "external_services" : "demo"
  app_network_type = var.airgap_package_url != "" ? "airgap" : "online"
  install_type     = "${local.app_data_mode}-${local.app_network_type}"
}

# Settings for automated PTFE installation
data "template_file" "repl_ptfe_config" {
  template = local.rptfeconf[local.install_type]

  vars = {
    hostname               = module.lb.endpoint
    enc_password           = local.encryption_password
    iact_subnet_list       = var.iact_subnet_list
    iact_subnet_time_limit = var.iact_subnet_time_limit
    pg_user                = var.postgresql_user
    pg_password            = var.postgresql_password
    pg_netloc              = var.postgresql_address
    pg_dbname              = var.postgresql_database
    pg_extra_params        = var.postgresql_extra_params
    aws_access_key_id      = var.aws_access_key_id
    aws_secret_access_key  = var.aws_secret_access_key
    s3_bucket_name         = var.s3_bucket
    s3_bucket_region       = var.s3_region
  }
}

# Settings for automated replicated installation.
data "template_file" "repl_config" {
  template = local.replconf[local.install_type]

  vars = {
    console_password = random_pet.console_password.id
    proxy_url        = var.http_proxy_url
    release_sequence = var.release_sequence
  }
}

locals {
  internal_airgap_url = "http://${aws_elb.cluster_api.dns_name}:${local.assistant_port}/setup-files/replicated.tar.gz?token=${random_string.setup_token.result}"
}

data "template_file" "cloud_config" {
  count    = var.primary_count
  template = file("${path.module}/templates/cloud-config.yaml")

  vars = {
    hostname        = module.lb.endpoint
    license_b64     = filebase64(var.license_file)
    install_ptfe_sh = filebase64("${path.module}/files/install-ptfe.sh")
    # Needed for Airgap installations
    airgap_package_url   = var.airgap_package_url
    airgap_installer_url = var.airgap_package_url == "" ? "" : count.index == 0 ? var.airgap_installer_url : local.internal_airgap_url
    bootstrap_token      = "${random_string.bootstrap_token_id.result}.${random_string.bootstrap_token_suffix.result}"
    cluster_api_endpoint = "${aws_elb.cluster_api.dns_name}:6443"
    setup_token          = random_string.setup_token.result
    primary_pki_url      = "http://${aws_elb.cluster_api.dns_name}:${local.assistant_port}/api/v1/pki-download?token=${random_string.setup_token.result}"
    role_id              = count.index
    health_url           = "http://${aws_elb.cluster_api.dns_name}:${local.assistant_port}/healthz"
    assistant_host       = "http://${aws_elb.cluster_api.dns_name}:${local.assistant_port}"
    assistant_token      = random_string.setup_token.result
    proxy_url            = var.http_proxy_url
    installer_url        = var.installer_url
    weave_cidr           = var.weave_cidr
    repl_cidr            = var.repl_cidr
    ca_bundle_url        = var.ca_bundle_url
    import_key           = var.import_key
    startup_script       = base64encode(var.startup_script)
    role                 = count.index == 0 ? "main" : "primary"
    distro               = var.distribution
    rptfeconf            = base64encode(data.template_file.repl_ptfe_config.rendered)
    replconf             = base64encode(data.template_file.repl_config.rendered)
  }
}

data "template_cloudinit_config" "config" {
  count         = var.primary_count
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_config[count.index].rendered
  }
}

data "template_file" "cloud_config_secondary" {
  template = file("${path.module}/templates/cloud-config-secondary.yaml")

  vars = {
    install_ptfe_sh      = filebase64("${path.module}/files/install-ptfe.sh")
    bootstrap_token      = "${random_string.bootstrap_token_id.result}.${random_string.bootstrap_token_suffix.result}"
    cluster_api_endpoint = "${aws_elb.cluster_api.dns_name}:6443"
    health_url           = "http://${aws_elb.cluster_api.dns_name}:${local.assistant_port}/healthz"
    assistant_host       = "http://${aws_elb.cluster_api.dns_name}:${local.assistant_port}"
    assistant_token      = random_string.setup_token.result
    proxy_url            = var.http_proxy_url
    installer_url        = var.installer_url
    role                 = "secondary"
    airgap_installer_url = var.airgap_package_url == "" ? "" : local.internal_airgap_url
    ca_bundle_url        = var.ca_bundle_url
    import_key           = var.import_key
  }
}

data "template_cloudinit_config" "config_secondary" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_config_secondary.rendered
  }
}

data "template_file" "ssh_config" {
  template = file("${path.module}/templates/ssh_config")

  vars = {
    hostname     = element(aws_instance.primary.*.public_ip, 0)
    ssh_user     = var.ssh_user != "" ? var.ssh_user : local.default_ssh_user
    keyfile_path = module.common.ssh_priv_key_file
  }
}

