module "aws_lb_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.9.1"
  name = var.name
  attach_aws_lb_controller_policy      = var.attach_aws_lb_controller_policy
   # Pod Identity Associations
  association_defaults = var.association_defaults
  associations = var.association
}