provider "minio" {
  alias          = "nas"
  minio_server   = data.sops_file.s3_secrets.data["minio_server"]
  minio_user     = data.onepassword_item.minio.username
  minio_password = data.onepassword_item.minio.password
}

provider "onepassword" {
  url = data.sops_file.s3_secrets.data["1pwconnect_url"]
  token = data.sops_file.s3_secrets.data["1pwconnect_token"]
}
