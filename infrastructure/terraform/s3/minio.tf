locals {
  minio_buckets = [
    "loki",
    "volsync",
    "crunchy-postgres",
    "zipline"
  ]
}

module "onepassword_item_minio" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Services"
  item   = "Minio"
}

module "minio_bucket" {
  for_each         = toset(local.minio_buckets)
  source           = "./modules/minio_bucket"
  bucket_name      = each.key
  is_public        = false
  owner_access_key = lookup(module.onepassword_item_minio.fields, "${each.key}_access_key", null)
  owner_secret_key = lookup(module.onepassword_item_minio.fields, "${each.key}_secret_key", null)
  providers = {
    minio = minio.nas
  }
}
output "minio_bucket_outputs" {
  value     = module.minio_bucket
  sensitive = true
}
