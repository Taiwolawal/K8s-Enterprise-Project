variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_endpoint_private_access" {
  type = bool
}

variable "cluster_endpoint_public_access" {
  type = bool
}

variable "cluster_addons" {
  type = map(any)
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "authentication_mode" {
  type = string
}


variable "eks_managed_node_groups" {
  type = map(any)
}

variable "enable_cluster_creator_admin_permissions" {
  type = bool
}

variable "node_security_group_additional_rules" {
  type = map(any)
}

variable "access_entries" {
  type    = map(any)
  default = {}
}
