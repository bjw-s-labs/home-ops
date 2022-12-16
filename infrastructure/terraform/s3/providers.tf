provider "minio" {
  alias          = "nas"
  minio_server   = data.sops_file.s3_secrets.data["minio_server"]
  minio_user     = local.minio_admin_user
  minio_password = local.minio_admin_password
}
