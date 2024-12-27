module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.48.0"
  role_name         = var.role_name
  create_role       = var.create_role
  role_requires_mfa = var.role_requires_mfa
  inline_policy_statements = var.inline_policy_statements
  trusted_role_arns = var.trusted_role_arns
}