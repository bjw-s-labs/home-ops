output "bucket_id" {
  value     = garage_bucket.bucket.id
  sensitive = false
}

output "access_key_id" {
  value     = garage_key.access_key.access_key_id
  sensitive = false
}

output "secret_key" {
  value     = garage_key.access_key.secret_access_key
  sensitive = true
}
