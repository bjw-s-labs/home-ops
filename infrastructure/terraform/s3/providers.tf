provider "minio" {
  alias          = "nas"
  minio_server   = "s3.bjw-s.dev"
  minio_user     = module.onepassword_item_minio.fields.username
  minio_password = module.onepassword_item_minio.fields.password
}

provider "garage" {
  alias  = "nas"
  host   = "nas.bjw-s.tech:3911"
  scheme = "http"
  token  = module.onepassword_item_garage.fields.admin_api_token
}
