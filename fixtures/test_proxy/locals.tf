locals {
  mitmproxy_selected = var.mitmproxy_ca_certificate_secret != null && var.mitmproxy_ca_private_key_secret != null
  ssm_policy_arn     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  http_proxy_port    = var.http_proxy_port
}