locals {
  buckets = [
    "thanos",
    "loki",
    "cnpg",
    "volsync"
  ]
}

module "onepassword_item_garage" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Automation"
  item   = "garage"
}

module "garage_bucket" {
  for_each    = toset(local.buckets)
  source      = "./modules/garage_bucket"
  bucket_name = each.key
  providers = {
    garage = garage.nas
  }
}
output "garage_bucket_outputs" {
  value     = module.garage_bucket
  sensitive = true
}

resource "garage_key" "admin_access_key" {
  name              = "admin"
  provider          = garage.nas
  permissions = {
    "create_bucket" = true
  }
}
resource "garage_bucket_key" "admin" {
  for_each      = toset(local.buckets)
  provider      = garage.nas
  bucket_id     = module.garage_bucket[each.key].bucket_id
  access_key_id = garage_key.admin_access_key.id
  owner         = true
  read          = true
  write         = true
  depends_on = [
    module.garage_bucket
  ]
}
output "garage_admin_key" {
  value     = {
      access_key_id = garage_key.admin_access_key.access_key_id
      secret_key = garage_key.admin_access_key.secret_access_key
    }
  sensitive = true
}

# module "garage_bucket_thanos" {
#   # for_each    = toset(local.buckets)
#   source      = "./modules/garage_bucket"
#   bucket_name = "thanos"
#   providers = {
#     garage = garage.nas
#   }
#   owner_access_id  = module.onepassword_item_garage.fields.thanos_access_key_id
#   owner_secret_key = module.onepassword_item_garage.fields.thanos_secret_key
# }
# output "garage_bucket_thanos_outputs" {
#   value     = module.garage_bucket_thanos
#   sensitive = true
# }

# module "garage_bucket_loki" {
#   source      = "./modules/garage_bucket"
#   bucket_name = "loki"
#   providers = {
#     garage = garage.nas
#   }
#   owner_access_id  = module.onepassword_item_garage.fields.loki_access_key_id
#   owner_secret_key = module.onepassword_item_garage.fields.loki_secret_key
# }
# output "garage_bucket_loki_outputs" {
#   value     = module.garage_bucket_loki
#   sensitive = true
# }

# module "minio_bucket_loki" {
#   source      = "./modules/minio_bucket"
#   bucket_name = "loki"
#   providers = {
#     minio = minio.nas
#   }
#   user_name   = module.onepassword_item_minio.fields.loki_access_key
#   user_secret = module.onepassword_item_minio.fields.loki_secret_key
# }

# module "minio_bucket_postgresql" {
#   source      = "./modules/minio_bucket"
#   bucket_name = "postgresql"
#   providers = {
#     minio = minio.nas
#   }
#   user_name   = module.onepassword_item_minio.fields.postgresql_access_key
#   user_secret = module.onepassword_item_minio.fields.postgresql_secret_key
# }

# module "minio_bucket_volsync" {
#   source      = "./modules/minio_bucket"
#   bucket_name = "volsync"
#   providers = {
#     minio = minio.nas
#   }
#   user_name   = module.onepassword_item_minio.fields.volsync_access_key
#   user_secret = module.onepassword_item_minio.fields.volsync_secret_key
# }
