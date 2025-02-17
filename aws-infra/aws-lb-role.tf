data "aws_iam_policy_document" "aws_lbc" {
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

resource "aws_iam_role" "aws_lbc" {
  name               = "aws-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

resource "aws_iam_policy" "aws_lbc" {
  policy = file("./policies/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

resource "kubernetes_service_account" "aws_lbc" {
  metadata {
    name      = "aws-load-balancer-controller-sa"
    namespace = "kube-system"
  }
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  depends_on      = [kubernetes_service_account.aws_lbc, aws_iam_role.aws_lbc]
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller-sa"
  role_arn        = aws_iam_role.aws_lbc.arn
}