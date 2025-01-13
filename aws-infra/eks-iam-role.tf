resource "aws_iam_role" "eks" {
  name               = "role-eks-cluster"
  assume_role_policy = file("policies/role-eks.json")
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" # Grants the EKS control plane permissions to manage AWS resources and services.
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role" "nodes" {
  name               = "role-eks-nodes"
  assume_role_policy = file("policies/role-node.json")
}

# This policy now includes AssumeRoleForPodIdentity for the Pod Identity Agent also enables worker nodes to interact with EKS and AWS services.
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# Allows the CNI plugin to manage pod networking within the VPC.
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}




