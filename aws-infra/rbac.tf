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
    resources  = ["pods", "services", "deployment", "configmap", "secret"]
    verbs      = ["get", "list", "describe", "watch"]
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