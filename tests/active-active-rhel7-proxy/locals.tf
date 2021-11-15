locals {
  http_proxy_port = 3128

  common_tags = {
    Terraform   = "cloud"
    Environment = "team_tfe_dev"
    Description = "Active/Active on RHEL with Proxy scenario deployed from CircleCI"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  friendly_name_prefix = random_string.friendly_name.id
  ssh_user             = "ec2-user"
  ssm_policy_arn       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  test_name            = "${local.friendly_name_prefix}-test-active-active-rhel-proxy"
}
