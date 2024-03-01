output "bucket_id" {
  value     = minio_s3_bucket.bucket.id
  sensitive = false
}
