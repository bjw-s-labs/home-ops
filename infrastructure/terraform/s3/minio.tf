data "onepassword_vault" "services" {
  name = "Services"
}

data "onepassword_item" "minio" {
  vault = data.onepassword_vault.services.uuid
  title = "Minio"
}

locals {
  minio_users = data.onepassword_item.minio.section[index(data.onepassword_item.minio.section.*.label, "Other users")].field
}

module "minio_bucket_thanos" {
  source      = "./modules/minio_bucket"
  bucket_name = "thanos"
  providers = {
    minio = minio.nas
  }
  user_name   = local.minio_users[index(local.minio_users.*.label, "thanos_access_key")].value
  user_secret = local.minio_users[index(local.minio_users.*.label, "thanos_secret_key")].value
}

module "minio_bucket_loki" {
  source      = "./modules/minio_bucket"
  bucket_name = "loki"
  providers = {
    minio = minio.nas
  }
  user_name   = local.minio_users[index(local.minio_users.*.label, "loki_access_key")].value
  user_secret = local.minio_users[index(local.minio_users.*.label, "loki_secret_key")].value
}

module "minio_bucket_postgresql" {
  source      = "./modules/minio_bucket"
  bucket_name = "postgresql"
  providers = {
    minio = minio.nas
  }
  user_name   = local.minio_users[index(local.minio_users.*.label, "postgresql_access_key")].value
  user_secret = local.minio_users[index(local.minio_users.*.label, "postgresql_secret_key")].value
}

module "minio_bucket_volsync" {
  source      = "./modules/minio_bucket"
  bucket_name = "volsync"
  providers = {
    minio = minio.nas
  }
  user_name   = local.minio_users[index(local.minio_users.*.label, "volsync_access_key")].value
  user_secret = local.minio_users[index(local.minio_users.*.label, "volsync_secret_key")].value
}
