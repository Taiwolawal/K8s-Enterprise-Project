resource "aws_iam_role" "external_secret" {
  name = "external-secret-role"
  assume_role_policy = templatefile(
    "${path.root}/template/external-secret-role.tpl",
    {
      oidc_provider_arn = module.eks.oidc_provider_arn
    }
  )
}

resource "aws_iam_policy" "external_secret" {
  policy = file("./policies/external-secret.json")
  name   = "ExternalSecret"
}

resource "aws_iam_role_policy_attachment" "external_secret" {
  policy_arn = aws_iam_policy.external_secret.arn
  role       = aws_iam_role.external_secret.name
}

resource "kubernetes_namespace" "external_secret" {
  metadata {
    name = "external-secret"
  }
}

resource "kubernetes_service_account" "external_secret" {
  depends_on = [aws_iam_role.external_secret]
  metadata {
    name      = "external-secret-sa"
    namespace = "external-secret"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secret.arn
    }
  }
}




















































# resource "aws_iam_role" "externalsecrets-role" {
#   name = "externalsecrets_sa_role"
#   assume_role_policy = templatefile(
#     "${path.root}/template/external-secret-role.tpl",
#     {
#       eks_oidc_provider_arn = module.eks.oidc_provider_arn
#     }
#   )
# }

# resource "aws_iam_role_policy" "externalsecrets_sa_policy" {
#   name   = "externalsecrets_sa_policy"
#   role   = aws_iam_role.externalsecrets-role.name
#   policy = file("policies/secrets-manager-policy.json")
# }