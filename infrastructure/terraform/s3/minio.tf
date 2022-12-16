data "onepassword_vault" "services" {
  name = "Services"
}

data "onepassword_item" "minio" {
  vault = data.onepassword_vault.services.uuid
  title = "Minio"
}

locals {
  minio_admin_user = data.onepassword_item.minio.username
  minio_admin_password = data.onepassword_item.minio.password
  minio_other_user_data = merge([
    for field in data.onepassword_item.minio.section[index(data.onepassword_item.minio.section.*.label, "Other users")].field : {
      (field.label): field.value
    }
  ]...)
}

module "minio_bucket_thanos" {
  source      = "./modules/minio_bucket"
  bucket_name = "thanos"
  providers = {
    minio = minio.nas
  }
  user_name   = local.minio_other_user_data.thanos_access_key
  user_secret = local.minio_other_user_data.thanos_secret_key
}

module "minio_bucket_loki" {
  source      = "./modules/minio_bucket"
  bucket_name = "loki"
  providers = {
    minio = minio.nas
  }
  user_name   = local.minio_other_user_data.loki_access_key
  user_secret = local.minio_other_user_data.loki_secret_key
}

module "minio_bucket_postgresql" {
  source      = "./modules/minio_bucket"
  bucket_name = "postgresql"
  providers = {
    minio = minio.nas
  }
  user_name   = local.minio_other_user_data.postgresql_access_key
  user_secret = local.minio_other_user_data.postgresql_secret_key
}

module "minio_bucket_volsync" {
  source      = "./modules/minio_bucket"
  bucket_name = "volsync"
  providers = {
    minio = minio.nas
  }
  user_name   = local.minio_other_user_data.volsync_access_key
  user_secret = local.minio_other_user_data.volsync_secret_key
}
