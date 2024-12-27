module "iam_policy_assume" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version       = "5.48.0"
  name          = "allow-assume-eks-admin-iam-role"
  create_policy = true
  policy = var.policy
}