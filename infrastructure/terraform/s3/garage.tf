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
