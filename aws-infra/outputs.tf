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
  value = [module.sg-istio.security_group_id]
}

output "iam_user_name" {
  description = "The user's name"
  value       = module.iam_user.iam_user_name
}

output "policy_arns" {
  description = "The list of ARNs of policies directly assigned to the IAM user"
  value       = module.iam_user.policy_arns
}