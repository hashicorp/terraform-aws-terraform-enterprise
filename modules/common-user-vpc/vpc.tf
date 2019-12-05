data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "selected" {
  vpc_id = var.vpc_id
  tags   = var.subnet_tags
}

data "aws_subnet" "selected" {
  count = length(data.aws_subnet_ids.selected.ids)
  id    = tolist(data.aws_subnet_ids.selected.ids)[count.index]
}
