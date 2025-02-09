data "aws_iam_policy_document" "external_secret" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}
resource "aws_iam_role" "external_secret" {
  name               = "external-secret-role"
  assume_role_policy = data.aws_iam_policy_document.external_secret.json
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
  depends_on = [kubernetes_namespace.external_secret]
  metadata {
    name      = "external-secret-sa"
    namespace = "external-secret"
  }
}

resource "aws_eks_pod_identity_association" "external_secret" {
  depends_on      = [kubernetes_service_account.external_secret]
  cluster_name    = module.eks.cluster_name
  namespace       = "external-secret"
  service_account = "external-secret-sa"
  role_arn        = aws_iam_role.external_secret.arn
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