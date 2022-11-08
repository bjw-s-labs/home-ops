provider "minio" {
  alias          = "nas"
  minio_server   = data.sops_file.s3_secrets.data["minio_server"]
  minio_user     = data.sops_file.s3_secrets.data["minio_user"]
  minio_password = data.sops_file.s3_secrets.data["minio_password"]
}
