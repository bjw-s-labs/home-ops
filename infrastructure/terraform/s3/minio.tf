module "onepassword_item_minio" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Services"
  item   = "Minio"
}

module "minio_bucket_thanos" {
  source      = "./modules/minio_bucket"
  bucket_name = "thanos"
  providers = {
    minio = minio.nas
  }
  user_name   = module.onepassword_item_minio.fields.thanos_access_key
  user_secret = module.onepassword_item_minio.fields.thanos_secret_key
}

module "minio_bucket_loki" {
  source      = "./modules/minio_bucket"
  bucket_name = "loki"
  providers = {
    minio = minio.nas
  }
  user_name   = module.onepassword_item_minio.fields.loki_access_key
  user_secret = module.onepassword_item_minio.fields.loki_secret_key
}

module "minio_bucket_postgresql" {
  source      = "./modules/minio_bucket"
  bucket_name = "postgresql"
  providers = {
    minio = minio.nas
  }
  user_name   = module.onepassword_item_minio.fields.postgresql_access_key
  user_secret = module.onepassword_item_minio.fields.postgresql_secret_key
}

module "minio_bucket_volsync" {
  source      = "./modules/minio_bucket"
  bucket_name = "volsync"
  providers = {
    minio = minio.nas
  }
  user_name   = module.onepassword_item_minio.fields.volsync_access_key
  user_secret = module.onepassword_item_minio.fields.volsync_secret_key
}
