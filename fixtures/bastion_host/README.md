# FIXTURE: TFE Test Bastion Host Module

This module creates a bastion host in order to SSH to the TFE instance(s) for DEVELOPMENT purposes only. NOT recommended for Prod.

## Example usage

```hcl
module "bastion_host" {
  source    = "../../fixtures/bastion_host"
  subnet_id = module.public_active_active.private_subnet_ids[0]
  name      = local.friendly_name_prefix
  key_name  = var.key_name
  vpc_id    = module.public_active_active.network_id
}
```

## Resources

- [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
- [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)
- [iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)
- [iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)
