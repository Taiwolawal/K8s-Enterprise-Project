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

    #  EKS K8s API cluster needs to be able to talk with the EKS worker nodes with port 15017/TCP and 15012/TCP which is used by Istio
    #  Istio in order to create sidecar needs to be able to communicate with webhook and for that network passage to EKS is needed.
    # ingress_15017 = {
    #   description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
    #   protocol                      = "TCP"
    #   from_port                     = 15017
    #   to_port                       = 15017
    #   type                          = "ingress"
    #   source_cluster_security_group = true
    # }
    # ingress_15012 = {
    #   description                   = "Cluster API to nodes ports/protocols"
    #   protocol                      = "TCP"
    #   from_port                     = 15012
    #   to_port                       = 15012
    #   type                          = "ingress"
    #   source_cluster_security_group = true
    # }

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
