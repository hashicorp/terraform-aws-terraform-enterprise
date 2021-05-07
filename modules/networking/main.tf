#################################################
# AZs
#################################################
data "aws_availability_zones" "available" {
  state = "available"
}

#################################################
# VPC
#################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  azs                     = data.aws_availability_zones.available.names
  cidr                    = var.network_cidr
  create_igw              = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = true
  map_public_ip_on_launch = true
  name                    = "${var.friendly_name_prefix}-tfe-vpc"
  one_nat_gateway_per_az  = false
  private_subnets         = var.network_private_subnet_cidrs
  public_subnets          = var.network_public_subnet_cidrs
  single_nat_gateway      = false
  tags                    = var.common_tags

  igw_tags = {
    Name = "${var.friendly_name_prefix}-tfe-igw"
  }
  nat_eip_tags = {
    Name = "${var.friendly_name_prefix}-tfe-nat-eip"
  }
  nat_gateway_tags = {
    Name = "${var.friendly_name_prefix}-tfe-tgw"
  }
  private_route_table_tags = {
    Name = "${var.friendly_name_prefix}-tfe-rtb-private"
  }
  private_subnet_tags = {
    Name = "${var.friendly_name_prefix}-private"
  }
  public_route_table_tags = {
    Name = "${var.friendly_name_prefix}-tfe-rtb-public"
  }
  public_subnet_tags = {
    Name = "${var.friendly_name_prefix}-public"
  }
  vpc_tags = {
    Name = "${var.friendly_name_prefix}-tfe-vpc"
  }
}

#################################################
# Internet Gateway
#################################################
resource "aws_internet_gateway" "igw" {
  count = var.deploy_vpc == true ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-igw" },
    var.common_tags
  )
}

#################################################
# Elastic IPs
#################################################
resource "aws_eip" "nat_eip" {
  count = var.deploy_vpc == true && length(var.network_public_subnet_cidrs) > 0 ? length(var.network_public_subnet_cidrs) : 0

  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-nat-eip" },
    var.common_tags
  )
}

#################################################
# NAT Gateways
#################################################
resource "aws_nat_gateway" "ngw" {
  count = var.deploy_vpc == true && length(var.network_public_subnet_cidrs) > 0 ? length(var.network_public_subnet_cidrs) : 0

  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  depends_on = [
    aws_internet_gateway.igw,
    aws_eip.nat_eip,
    aws_subnet.public,
  ]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-ngw-${count.index}" },
    var.common_tags
  )
}

#################################################
# Route Tables & Routes
#################################################
resource "aws_route_table" "rtb_public" {
  count = var.deploy_vpc == true ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-rtb-public" },
    var.common_tags
  )
}

resource "aws_route" "route_public" {
  count = var.deploy_vpc == true ? 1 : 0

  route_table_id         = aws_route_table.rtb_public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table" "rtb_private" {
  count = var.deploy_vpc == true ? length(var.network_private_subnet_cidrs) : 0

  vpc_id = aws_vpc.main[0].id

  depends_on = [aws_nat_gateway.ngw]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-rtb-private-${count.index}" },
    var.common_tags
  )
}

resource "aws_route" "route_private" {
  count = var.deploy_vpc == true ? length(var.network_private_subnet_cidrs) : 0

  route_table_id         = element(aws_route_table.rtb_private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
}

resource "aws_route_table_association" "rtbassoc_public" {
  count = var.deploy_vpc == true ? length(var.network_public_subnet_cidrs) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.rtb_public[0].id
}

resource "aws_route_table_association" "rtbassoc_private" {
  count = var.deploy_vpc == true ? length(var.network_private_subnet_cidrs) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.rtb_private.*.id, count.index)
}

locals {
  network_id          = var.deploy_vpc == true ? aws_vpc.main[0].id : ""
  bastion_host_subnet = var.deploy_vpc == true ? aws_subnet.public[0].id : ""
}
