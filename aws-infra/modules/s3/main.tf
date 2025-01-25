module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.5.0"
  bucket = var.bucket
  force_destroy = var.force_destroy
}