module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.48.0"
  name                          = var.name
  force_destroy                 = var.force_destroy
  create_user                   = var.create_user
  password_length               = var.password_length
  password_reset_required       = var.password_reset_required
}