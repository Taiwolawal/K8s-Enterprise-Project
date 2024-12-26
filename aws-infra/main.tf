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
  principal_arn     = aws_iam_role.eks_admin.arn
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

module "sg-istio" {
  source                   = "./modules/sg-istio"
  description              = var.sg-istio-description
  name                     = var.sg-istio-name
  vpc_id                   = module.vpc.vpc_id
  create                   = var.create
  ingress_with_cidr_blocks = var.sg_istio_ingress_with_cidr_blocks
  egress_rules             = var.sg_istio_egress_rules
}