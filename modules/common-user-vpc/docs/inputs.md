# Terraform Enterprise: Clustering

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| prefix | Prefix for resource names | `string` | n/a | yes |
| vpc\_id | AWS VPC id to install into | `string` | n/a | yes |
| egress\_allow\_list | List of CIDR blocks we allow the infrastructure to access | `set(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ingress\_allow\_list | list of CIDR blocks we allow to access the infrastructure | `set(string)` | `[]` | no |
| subnet\_tags | tags to use to match subnets to use | `map` | `{}` | no |
| tags | Map of tags to add to security groups | `map(string)` | `{}` | no |

