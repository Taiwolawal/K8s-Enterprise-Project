##############
# VPC Variables
###############
variable "region" {
  default = "us-east-1"
}

variable "vpc_name" {
  type = string
}

variable "cidr" {
  type    = string
  default = ""
}

variable "azs" {
  type    = list(any)
  default = []
}

variable "private_subnets" {
  type    = list(any)
  default = []
}

variable "public_subnets" {
  type    = list(any)
  default = []
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
}

variable "single_nat_gateway" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "enable_dns_support" {
  type = bool
}

variable "create_database_subnet_group" {
  type    = bool
  default = true
}

variable "database_subnets" {
  type    = list(any)
  default = []
}

variable "database_subnet_group_name" {
  type = string
}

variable "public_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "private_subnet_tags" {
  type    = map(any)
  default = {}
}


################
# EKS variables
################

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

variable "authentication_mode" {
  type = string
}

variable "enable_cluster_creator_admin_permissions" {
  type = bool
}

variable "eks_managed_node_groups" {
  type = map(any)
}

variable "node_security_group_additional_rules" {
  type    = map(any)
  default = {}
}

# ###############
# Database variables
# ###############
variable "identifier" {
  type = string
}
variable "create_db_instance" {
  type = bool
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "allocated_storage" {
  type        = number
  description = "The allocated storage in gigabytes"
}
variable "db_name" {
  type = string
}

variable "manage_master_user_password" {
  type = bool
}

variable "port" {
  type = string
}

variable "username" {
  type = string
}

variable "family" {
  type    = string
  default = "mysql8.0"
}
variable "major_engine_version" {
  type    = string
  default = "8.0"
}
variable "deletion_protection" {
  type    = bool
  default = false
}

# ###############
# Security-Group-RDS variables
# ###############
variable "sg-rds-name" {
  type = string
}

variable "sg-rds-description" {
  type = string
}

variable "create" {
  type    = bool
  default = false
}

# variable "ingress_cidr_blocks" {
#   type    = any
#   default = []
# }

variable "sg_rds_ingress_cidr_blocks" {
  type = list(string)
}

variable "ingress_rules" {
  type    = any
  default = []
}

# variable "ingress_with_cidr_blocks" {
#   type    = any
#   default = []
# }

variable "sg_rds_ingress_with_cidr_blocks" {
  type    = any
  default = []
}


# variable "egress_with_cidr_blocks" {
#   type    = any
#   default = []
# }

variable "sg_rds_egress_with_cidr_blocks" {
  type    = any
  default = []
}

variable "sg_rds_egress_cidr_blocks" {
  type    = any
  default = []
}

# variable "egress_cidr_blocks" {
#   type    = any
#   default = []
# }

variable "egress_rules" {
  type    = any
  default = []
}

# ###############
# Security-Group Istio variables
# ###############

variable "sg-istio-description" {
  type = string
}

variable "sg-istio-name" {
  type = string
}

variable "sg_istio_ingress_with_cidr_blocks" {
  type    = any
  default = []
}

variable "sg_istio_egress_rules" {
  type    = any
  default = []
}

# ###############
# IAM Admin & Developer variables
# ###############

variable "admin_usernames" {
  description = "List of admin usernames"
  type        = list(string)
}

variable "developer_usernames" {
  description = "List of developer usernames"
  type        = list(string)
}

variable "force_destroy" {
  type    = bool
  default = true
}

variable "create_user" {
  type    = bool
  default = true
}

variable "password_length" {
  type    = number
  default = 30
}

variable "password_reset_required" {
  type    = bool
  default = true
}



# ###############
# IAM Developer variables
# ###############




# ###############
# IAM Group variables
# ###############
variable "admin_iam_group_name" {
  type = string
}

variable "developer_iam_group_name" {
  type = string
}

variable "create_group" {
  type = bool
}

# variable "attach_iam_self_management_policy" {
#   type = bool
# }

# variable "group_users" {
#   type = list(string)
# }



# ###############
# IAM Policy variables
# ###############

variable "admin_iam_policy_name" {
  type = string
}

variable "developer_iam_policy_name" {
  type = string
}

variable "create_policy" {
  type = bool
}


# ###############
# Role variables
# ###############
variable "admin_role_name" {
  type = string
}

variable "developer_role_name" {
  type = string
}

variable "create_assume_role" {
  type = bool
}

variable "role_requires_mfa" {
  type = bool
}

# variable "custom_role_policy_arns" {
#   type = list(string)
# }


# ###############
# IAM Policy Assume variables
# ###############

variable "admin_assume_iam_policy" {
  type = string
}

variable "developer_assume_iam_policy" {
  type = string
}

variable "create_iam_assume_policy" {
  type = bool
}
