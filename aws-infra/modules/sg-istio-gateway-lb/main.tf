module "sg-istio" {
  source                   = "terraform-aws-modules/security-group/aws"
  version                  = "5.2.0"
  name                     = var.name
  description              = var.description
  vpc_id                   = var.vpc_id
  create                   = var.create
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.egress_with_cidr_blocks  
}