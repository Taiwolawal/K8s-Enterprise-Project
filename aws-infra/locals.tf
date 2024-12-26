locals {
  node_security_group_rules = {
    ingress_15017 = {
      description                   = "Cluster API to Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_rds = {
      description              = "Allow EKS worker nodes to connect to RDS"
      protocol                 = "TCP"
      from_port                = 3306
      to_port                  = 3306
      type                     = "ingress"
      source_security_group_id = module.sg-rds.security_group_id
    }

    ingress_istio = {
      description              = "Allow EKS worker nodes to connect to RDS"
      protocol                 = "TCP"
      from_port                = 3306
      to_port                  = 3306
      type                     = "ingress"
      source_security_group_id = module.sg-istio.security_group_id
    }
  }
}