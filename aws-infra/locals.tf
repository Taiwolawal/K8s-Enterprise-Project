locals {
  node_security_group_rules = {

    ingress_rds = {
      description                   = "Allow EKS worker nodes to connect to RDS"
      protocol                      = "TCP"
      from_port                     = 3306
      to_port                       = 3306
      type                          = "ingress"
      source_cluster_security_group = true
      source_security_group_id      = module.sg-rds.security_group_id[0]
    }

  }

  access_entries = {
    admin = {
      kubernetes_groups = ["admin"]
      principal_arn     = module.admin_iam_role.iam_role_arn

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
            namespaces = []
          }
        }
      }
    }

    developer = {
      kubernetes_groups = ["developer"]
      principal_arn     = module.developer_iam_role.iam_role_arn

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["developer"]
          }
        }
      }
    }
  }


}
