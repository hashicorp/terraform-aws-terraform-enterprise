# Terraform Enterprise: Clustering

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| install\_id | Identifier for installation | `string` | n/a | yes |
| vpc\_id | AWS VPC id to install into | `string` | n/a | yes |
| database\_name | name of the initial database | `string` | `"tfe"` | no |
| database\_username | username of the initial user | `string` | `"tfe"` | no |
| prefix | string to prefix all resources with | `string` | `""` | no |
| rds\_instance\_class | instance class of the database | `string` | `"db.r5.large"` | no |
| rds\_subnet\_tags | tags to use to match subnets to use | `map` | `{}` | no |

