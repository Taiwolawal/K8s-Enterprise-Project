data "aws_iam_policy_document" "velero" {
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

resource "aws_iam_role" "velero" {
  name               = "velero-role"
  assume_role_policy = data.aws_iam_policy_document.velero.json
}

resource "aws_iam_policy" "velero" {
  policy = templatefile(
    "${path.root}/template/velero-policy.tpl",
    {
      velero_s3_bucket = module.s3_bucket_velero.velero_bucket_arn
    }
  )
  name = "Velero"
}

resource "aws_iam_role_policy_attachment" "velero" {
  policy_arn = aws_iam_policy.velero.arn
  role       = aws_iam_role.velero.name
}

resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
}

resource "kubernetes_service_account" "velero" {
  metadata {
    name      = "velero-sa"
    namespace = "velero"
  }
}

resource "aws_eks_pod_identity_association" "velero" {
  cluster_name    = module.eks.cluster_name
  namespace       = "velero"
  service_account = "velero-sa"
  role_arn        = aws_iam_role.velero.arn
}