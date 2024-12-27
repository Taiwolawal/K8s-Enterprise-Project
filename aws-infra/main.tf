data "aws_availability_zones" "azs" {}

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
  tags                         = var.tags
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
  node_security_group_additional_rules     = local.node_security_group_rules
  tags                                     = var.tags
}

resource "aws_eks_access_entry" "admin-user" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = module.admin_ia
  kubernetes_groups = ["admin"]
}

resource "aws_eks_access_entry" "developer-user" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_user.developer.arn
  kubernetes_groups = ["developer"]
}

resource "kubernetes_namespace" "developer" {
  metadata {
    name = "developer"

    labels = {
      managed_by = "terraform"
    }
  }
}

resource "kubernetes_role" "developer" {
  metadata {
    name      = "developer-role"
    namespace = "developer"
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods", "services", "delpoyment"]
    verbs      = ["get", "list", "describe"]
  }

}

resource "kubernetes_role_binding" "developer" {
  metadata {
    name      = "developer-role-binding"
    namespace = "developer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "developer-role"
  }
  subject {
    kind      = "Group"
    name      = "developer"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "cluster_viewer" {
  metadata {
    name = "admin-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["get", "list", "watch", "describe"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["get", "list", "create"]
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["get", "list", "describe"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec", "pods/attach"]
    verbs      = ["get", "list", "create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "create", "describe", "delete", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_viewer" {
  metadata {
    name = "admin-cluster-role-binding"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "admin-cluster-role"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "Group"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
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
  vpc_security_group_ids      = [module.sg-rds.security_group_id]
  db_name                     = var.db_name
  username                    = var.username
  manage_master_user_password = var.manage_master_user_password
  port                        = var.port
  subnet_ids                  = module.vpc.private_subnets
  family                      = var.family
  major_engine_version        = var.major_engine_version
  deletion_protection         = var.deletion_protection
  tags                        = var.tags
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

module "sg-istio-gateway-lb" {
  source                   = "./modules/sg-istio-gateway-lb"
  description              = var.sg-istio-description
  name                     = var.sg-istio-name
  vpc_id                   = module.vpc.vpc_id
  create                   = var.create
  ingress_with_cidr_blocks = var.sg_istio_ingress_with_cidr_blocks
  egress_rules             = var.sg_istio_egress_rules
}

module "admin_iam_users" {
  source  = "./modules/iam/user"
  for_each                     = toset(var.admin_usernames)
  name                         = each.key
  force_destroy                = var.force_destroy
  create_user                  = var.create_user
  password_length              = var.password_length
  password_reset_required      = var.password_reset_required
}

module "developer_iam_users" {
  source  = "./modules/iam/user"
  for_each                     = toset(var.developer_usernames)
  name                         = each.key
  force_destroy                = var.force_destroy
  create_user                  = var.create_user
  password_length              = var.password_length
  password_reset_required      = var.password_reset_required
}

module "admin_iam_group" {
  source = "./modules/iam/group"
  name                            = var.admin_iam_group_name
  attach_iam_self_management_policy = var.attach_iam_self_management_policy
  create_group                      = var.create_group
  group_users                       = [module.admin_iam_users.iam_user_name]
  custom_group_policy_arns          = var.custom_group_policy_arns
}

module "developer_iam_group" {
  source = "./modules/iam/group"
  name                              = var.developer_iam_group_name
  attach_iam_self_management_policy = var.attach_iam_self_management_policy
  create_group                      = var.create_group
  group_users                       = [module.developer_iam_users.iam_user_name]
  custom_group_policy_arns          = var.custom_group_policy_arns
}

module "admin_iam_policy" {
  source = "./modules/iam/policy"
  name = var.admin_iam_policy_name
  create_policy = var.create_policy
  policy = file("policies/eks-admin-access.json")
}

module "developer_iam_policy" {
  source = "./modules/iam/policy"
  name = var.developer_iam_policy_name
  create_policy = var.create_policy
  policy = file("policies/eks-developer-access.json")
}

module "admin_iam_role" {
  source = "./modules/iam/role"
  role_name = var.admin_role_name
  create_role = var.create_assume_role
  role_requires_mfa = var.role_requires_mfa
  custom_role_policy_arns = [module.admin_iam_policy.arn]
  trusted_role_arns =  ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] 
}

module "developer_iam_role" {
  source = "./modules/iam/role"
  role_name = var.developer_role_name
  create_role = var.create_assume_role
  role_requires_mfa = var.role_requires_mfa
  custom_role_policy_arns = [ module.developer_iam_policy.arn ]
  trusted_role_arns =  ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] 
}

module "iam_policy_assume_iam_role_admin" {
  source = "./modules/iam/assume-role"
  name = var.admin_assume_iam_policy
  create_policy = var.create_iam_assume_policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.admin_iam_role.arn
      },
    ]
  })
}

module "iam_policy_assume_iam_role_developer" {
  source = "./modules/iam/assume-role"
  name = var.developer_assume_iam_policy
  create_policy = var.create_iam_assume_policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.developer_iam_role.arn
      },
    ]
  })
}