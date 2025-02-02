##############
# VPC Variables
###############
vpc_name                     = "EKS-VPC"
cidr                         = "10.0.0.0/16"
region                       = "us-east-1"
public_subnets               = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets              = ["10.0.3.0/24", "10.0.4.0/24"]
enable_nat_gateway           = true
single_nat_gateway           = true
enable_dns_hostnames         = true
enable_dns_support           = true
create_database_subnet_group = true
database_subnets             = ["10.0.5.0/24", "10.0.6.0/24"]
database_subnet_group_name   = "db-subnet"
public_subnet_tags = {
  "kubernetes.io/role/elb" = 1
}
private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = 1
}


################
# EKS variables
################
cluster_name                    = "dev-eks"
cluster_version                 = "1.30"
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = true
cluster_addons = {
  coredns                = {}
  eks-pod-identity-agent = {}
  kube-proxy             = {}
  vpc-cni                = {}
}
eks_managed_node_groups = {
  dev-eks = {
    min_size       = 3
    max_size       = 4
    desired_size   = 3
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
  }
}
enable_cluster_creator_admin_permissions = true
authentication_mode                      = "API"


# ###############
# Database variables
# ###############
identifier                  = "database1"
create_db_instance          = false
engine                      = "mysql"
engine_version              = "8.0.33"
instance_class              = "db.t2.medium"
allocated_storage           = 5
db_name                     = "demodb"
username                    = "db_name"
port                        = "3306"
family                      = "mysql8.0"
manage_master_user_password = "true"
major_engine_version        = "8.0"
deletion_protection         = false

# ###############
# Security-Group RDS variables
# ###############
sg-rds-description         = "Security Group for RDS"
sg-rds-name                = "mysql-rds-sg"
create                     = true
sg_rds_ingress_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
sg_rds_egress_cidr_blocks  = ["10.0.0.0/16"]
ingress_rules              = []
egress_rules               = []
sg_rds_ingress_with_cidr_blocks = [
  {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "open port range 3306/tcp ingress rule"
    cidr_blocks = "10.0.0.0/16"
  }
]
sg_rds_egress_with_cidr_blocks = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    description = "open port"
    cidr_blocks = "0.0.0.0/0"
  }
]


# ###############
# IAM Admin & Developer variables
# ###############
admin_usernames     = ["t.l", "ukeme", "akuracy", "nonso"]
developer_usernames = ["geetee", "drintech", "lateef", "kola"]

# ###############
# IAM Group variables
# ###############
admin_iam_group_name     = "admin"
developer_iam_group_name = "developer"
create_group             = true

# ###############
# IAM Policy variables
# ###############
admin_iam_policy_name     = "allow-eks-access-admin-policy"
developer_iam_policy_name = "allow-eks-access-developer-policy"
create_policy             = true

# ###############
# Role variables
# ###############
admin_role_name     = "admin_role"
developer_role_name = "developer_role"
create_assume_role  = true
role_requires_mfa   = false

# ###############
# IAM Policy Assume variables
# ###############
assume_eks_admin_iam_role          = "assume-eks-admin-iam-role"
assume_eks_developer_iam_role      = "assume-eks-developer-iam-role"
create_eks_assume_user_role_policy = true

# ###############
# S3 variables
# ###############
velero_bucket    = "velero-k8s-backup-bucket"
force_destroy_s3 = true


