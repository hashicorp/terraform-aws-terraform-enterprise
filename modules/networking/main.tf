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

  azs                            = data.aws_availability_zones.available.names
  cidr                           = var.network_cidr
  create_igw                     = true
  default_security_group_egress  = []
  default_security_group_ingress = []
  enable_dns_hostnames           = true
  enable_dns_support             = true
  enable_nat_gateway             = true
  manage_default_security_group  = true
  map_public_ip_on_launch        = true
  name                           = "${var.friendly_name_prefix}-tfe-vpc"
  one_nat_gateway_per_az         = false
  private_subnets                = var.network_private_subnet_cidrs
  public_subnets                 = var.network_public_subnet_cidrs
  single_nat_gateway             = false
  tags                           = var.common_tags

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

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.0"

  security_group_ids = [module.vpc.default_security_group_id]
  vpc_id             = module.vpc.vpc_id
  tags               = var.common_tags

  endpoints = {
    ec2 = {
      service             = "ec2"
      service_type        = "Interface"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    ec2messages = {
      private_dns_enabled = true
      service             = "ec2messages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.friendly_name_prefix}-tfe-ec2messages-vpc-endpoint"
      }
    }
    kms = {
      service             = "kms"
      service_type        = "Interface"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    s3 = {
      route_table_ids = module.vpc.private_route_table_ids
      service         = "s3"
      service_type    = "Gateway"
      tags = {
        Name = "${var.friendly_name_prefix}-tfe-s3-vpc-endpoint"
      }
    }
    ssm = {
      private_dns_enabled = true
      service             = "ssm"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.friendly_name_prefix}-tfe-ssm-vpc-endpoint"
      }
    }
    ssmmessages = {
      private_dns_enabled = true
      service             = "ssmmessages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.friendly_name_prefix}-tfe-ssmmessages-vpc-endpoint"
      }
    }
  }
}
