resource "aws_iam_role" "externalsecrets-role" {
  name = "externalsecrets_sa_role"
  assume_role_policy = templatefile(
    "${path.root}/template/external-secret-role.tpl",
    {
      eks_provider_arn = module.eks.oidc_provider_arn
    }
  )
}

resource "aws_iam_role_policy" "externalsecrets_sa_policy" {
  name   = "externalsecrets_sa_policy"
  role   = aws_iam_role.externalsecrets-role.name
  policy = file("policies/secrets-manager-policy.json")
}