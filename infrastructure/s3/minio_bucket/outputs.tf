output "secret_key" {
  value     = minio_iam_user.user.secret
  sensitive = true
}
