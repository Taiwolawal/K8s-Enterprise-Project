output "velero_bucket_name" {
    value = module.s3-bucket.s3_bucket_id
}

output "velero_bucket_arn" {
    value = module.s3-bucket.s3_bucket_arn
}