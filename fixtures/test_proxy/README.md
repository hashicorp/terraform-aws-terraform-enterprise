# FIXTURE: TFE Test Proxy Module

This module creates mitmproxy servers and Squid servers for use in
test modules.

## Example usage

```hcl
module "test_proxy" {
  source                          = "../../fixtures/test_proxy"
  subnet_id                       = module.private_tcp_active_active.private_subnet_ids[0]
  name                            = local.friendly_name_prefix
  key_name                        = var.key_name
  mitmproxy_ca_certificate_secret = data.aws_secretsmanager_secret.ca_certificate.arn
  mitmproxy_ca_private_key_secret = data.aws_secretsmanager_secret.ca_private_key.arn
  vpc_id                          = module.private_tcp_active_active.network_id

}
```

## Resources

- [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
- [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)
- [iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)
- [iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)
