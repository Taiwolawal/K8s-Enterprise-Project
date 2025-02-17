data "aws_availability_zones" "azs" {}
data "aws_caller_identity" "current" {}

module "vpc" {
  source                       = "./modules/vpc"
  vpc_name                     = var.vpc_name
  cidr                         = var.cidr
  azs                          = ["${var.region}a", "${var.region}b"]
  private_subnets              = var.private_subnets
  public_subnets               = var.public_subnets
  enable_nat_gateway           = var.enable_nat_gateway
  single_nat_gateway           = var.single_nat_gateway
  enable_dns_hostnames         = var.enable_dns_hostnames
  enable_dns_support           = var.enable_dns_support
  create_database_subnet_group = var.create_database_subnet_group
  database_subnets             = var.database_subnets
  database_subnet_group_name   = var.database_subnet_group_name
  public_subnet_tags           = var.public_subnet_tags
  private_subnet_tags          = var.private_subnet_tags
}

module "eks" {
  source                                   = "./modules/eks"
  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  cluster_endpoint_private_access          = var.cluster_endpoint_private_access
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  cluster_addons                           = var.cluster_addons
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  eks_managed_node_groups                  = var.eks_managed_node_groups
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  authentication_mode                      = var.authentication_mode
  access_entries                           = local.access_entries
  node_security_group_additional_rules     = local.node_security_group_rules
}

module "rds" {
  source                      = "./modules/rds"
  identifier                  = var.identifier
  create_db_instance          = var.create_db_instance
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  db_subnet_group_name        = module.vpc.database_subnet_group_name
  allocated_storage           = var.allocated_storage
  vpc_security_group_ids      = [module.sg-rds.security_group_id[0]]
  db_name                     = var.db_name
  username                    = var.username
  manage_master_user_password = var.manage_master_user_password
  port                        = var.port
  subnet_ids                  = module.vpc.private_subnets
  family                      = var.family
  major_engine_version        = var.major_engine_version
  deletion_protection         = var.deletion_protection
}

module "sg-rds" {
  source                   = "./modules/sg-rds"
  description              = var.sg-rds-description
  name                     = var.sg-rds-name
  vpc_id                   = module.vpc.vpc_id
  create                   = var.create
  ingress_cidr_blocks      = var.sg_rds_ingress_cidr_blocks
  ingress_rules            = var.ingress_rules
  ingress_with_cidr_blocks = var.sg_rds_ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.sg_rds_egress_with_cidr_blocks
  egress_cidr_blocks       = var.sg_rds_egress_cidr_blocks
  egress_rules             = var.egress_rules
}

# Admin User To Access Cluster
module "admin_iam_users" {
  source                  = "./modules/iam/user"
  for_each                = toset(var.admin_usernames)
  name                    = each.key
  force_destroy           = var.force_destroy
  create_user             = var.create_user
  password_length         = var.password_length
  password_reset_required = var.password_reset_required
}

# Create Group To Admin Users & Attach IAM Policy Assuming EKS
module "admin_iam_group" {
  source                   = "./modules/iam/group"
  name                     = var.admin_iam_group_name
  create_group             = var.create_group
  custom_group_policy_arns = [module.admin_iam_policy.arn]
  group_users              = [for user in module.admin_iam_users : user.iam_user_name]
}

# IAM Policy With Admin Access Inside AWS Account
module "admin_iam_policy" {
  source = "./modules/iam/policy"
  name   = var.admin_iam_policy_name
  # name          = "${var.admin_iam_policy_name}-${formatdate("YYYYMMDD", timestamp())}"
  create_policy = var.create_policy
  policy        = file("policies/eks-admin-access.json")
}

# IAM Role Granting Admin Privileges inside K8s & Share With Users
module "admin_iam_role" {
  source                  = "./modules/iam/role"
  role_name               = var.admin_role_name
  create_role             = var.create_assume_role
  role_requires_mfa       = var.role_requires_mfa
  custom_role_policy_arns = [module.admin_iam_policy.arn]
  trusted_role_arns       = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

module "allow_assume_eks_admins_iam_policy" {
  source        = "./modules/iam/policy"
  name          = var.assume_eks_admin_iam_role
  create_policy = true
  policy = templatefile(
    "${path.root}/template/assume-eks-admin-iam-policy.tpl",
    {
      assume_eks_admin_iam_policy = module.admin_iam_role.iam_role_arn
    }
  )
}

# Developer User To Access Cluster
module "developer_iam_users" {
  source                  = "./modules/iam/user"
  for_each                = toset(var.developer_usernames)
  name                    = each.key
  force_destroy           = var.force_destroy
  create_user             = var.create_user
  password_length         = var.password_length
  password_reset_required = var.password_reset_required
}

module "developer_iam_group" {
  source                   = "./modules/iam/group"
  name                     = var.developer_iam_group_name
  create_group             = var.create_group
  group_users              = [for user in module.developer_iam_users : user.iam_user_name]
  custom_group_policy_arns = [module.developer_iam_policy.arn]
}


module "developer_iam_policy" {
  source        = "./modules/iam/policy"
  name          = var.developer_iam_policy_name
  create_policy = var.create_policy
  policy        = file("policies/eks-developer-access.json")
}

module "developer_iam_role" {
  source                  = "./modules/iam/role"
  role_name               = var.developer_role_name
  create_role             = var.create_assume_role
  role_requires_mfa       = var.role_requires_mfa
  custom_role_policy_arns = [module.developer_iam_policy.arn]
  trusted_role_arns       = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

module "allow_assume_eks_developer_iam_policy" {
  source        = "./modules/iam/policy"
  name          = var.assume_eks_developer_iam_role
  create_policy = true
  policy = templatefile(
    "${path.root}/template/assume-eks-developer-iam-policy.tpl",
    {
      assume_eks_developer_iam_policy = module.developer_iam_role.iam_role_arn
    }
  )
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

module "s3_bucket_velero" {
  source        = "./modules/s3"
  bucket        = "${var.velero_bucket}-${random_string.random.result}"
  force_destroy = var.force_destroy_s3
}

