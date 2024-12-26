data "aws_caller_identity" "current" {}

 # Admin Role
resource "aws_iam_role" "eks_admin" {
  name = var.eks_admin_role
  assume_role_policy = var.admin_assume_role_policy
  description          = var.role_description
  max_session_duration = var.max_session_duration
  tags = var.tags
}

resource "aws_iam_policy" "eks_admin" {
  name = "AmazonEKSAdminPolicy"
  policy = var.eks_admin_policy
}

resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin.arn
}


resource "aws_iam_policy" "eks_assume_admin" {
  name = "AmazonEKSAssumeAdminPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "${aws_iam_role.eks_admin.arn}"
        }
    ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "manager" {
  user       = aws_iam_user.manager.name
  policy_arn = aws_iam_policy.eks_assume_admin.arn
}

 # Developer Role
resource "aws_iam_role" "eks_developer" {
  name = var.eks_developer_role
  assume_role_policy = var.developer_assume_role_policy
  description          = var.role_description
  max_session_duration = var.max_session_duration
  tags = var.tags
}