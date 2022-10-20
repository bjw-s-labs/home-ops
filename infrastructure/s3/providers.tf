provider "minio" {
  alias            = "nas"
  minio_server     = "s3.${data.sops_file.domains.data["ingress"]}"
  minio_access_key = data.sops_file.s3_secrets.data["minio_access_key"]
  minio_secret_key = data.sops_file.s3_secrets.data["minio_secret_key"]
}
