# VPC OUTPUT  
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}


# EKS OUTPUT  

output "cluster_name" {
  value = module.eks.cluster_name
}
output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "EKS oidc_provider_arn"
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_id" {
  value = module.eks.cluster_id
}

# Security Group OUTPUT  
output "rds-security_group_id" {
  value = [module.sg-rds.security_group_id]
}


output "admin_iam_user_names" {
  description = "The names of the admin IAM users"
  value       = { for key, user in module.admin_iam_users : key => user.iam_user_name }
}

output "developer_iam_user_names" {
  description = "The names of the developer IAM users"
  value       = { for key, user in module.developer_iam_users : key => user.iam_user_name }
}

output "admin_iam_role_arn" {
  description = "Admin Role ARN"
  value       = module.admin_iam_role.iam_role_arn
}

output "develop_iam_role_arn" {
  description = "Admin Role ARN"
  value       = module.developer_iam_role.iam_role_arn
}





