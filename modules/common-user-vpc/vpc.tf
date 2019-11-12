data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "selected" {
  vpc_id = var.vpc_id
  tags   = var.subnet_tags
}

data "aws_subnet" "selected" {
  # https://github.com/terraform-providers/terraform-provider-aws/issues/7522
  for_each = data.aws_subnet_ids.selected.ids
  id       = each.value
}
