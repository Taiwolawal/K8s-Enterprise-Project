module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.31.6"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_addons = var.cluster_addons
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  eks_managed_node_groups         = var.eks_managed_node_groups
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  authentication_mode = var.authentication_mode
  access_entries = var.access_entries
  node_security_group_additional_rules = var.node_security_group_additional_rules
}