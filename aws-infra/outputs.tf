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

output "rds-security_group_id" {
  value = [module.sg-rds.security_group_id]
}

output "istio-gateway-lb-security_group_id" {
  value = [module.sg-istio-gateway-lb.security_group_id]
}

output "admin_iam_user_name" {
  description = "The user's name"
  value       = module.admin_iam_users.iam_user_name
}

output "developer_iam_user_name" {
  description = "The user's name"
  value       = module.developer_iam_users.iam_user_name
}

output "admin_iam_role_arn" {
  description = "Admin Role ARN"
  value       = module.admin_iam_role.iam_role_arn
}

output "develop_iam_role_arn" {
  description = "Admin Role ARN"
  value       = module.developer_iam_role.iam_role_arn
}


