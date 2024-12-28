module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"
  name            = var.vpc_name
  cidr            = var.cidr
  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  create_database_subnet_group = var.create_database_subnet_group
  database_subnets             = var.database_subnets
  database_subnet_group_name   = var.database_subnet_group_name
  public_subnet_tags = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
}