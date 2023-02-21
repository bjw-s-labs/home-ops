terraform {
  required_providers {
    garage = {
      source = "terraform-registry.bjw-s.dev/bjw-s/garage"
    }
  }
}

resource "garage_bucket" "bucket" {
}

resource "garage_bucket_global_alias" "alias" {
  bucket_id = garage_bucket.bucket.id
  alias     = var.bucket_name
  depends_on = [
    garage_bucket.bucket
  ]
}

resource "garage_key" "access_key" {
  name              = "${var.bucket_name}-owner"
  secret_access_key = var.owner_secret_key != null ? var.owner_secret_key : null
  permissions = {
    "create_bucket" = false
  }
}

resource "garage_bucket_key" "bucket_key_owner" {
  bucket_id     = garage_bucket.bucket.id
  access_key_id = garage_key.access_key.access_key_id
  owner         = true
  read          = true
  write         = true
  depends_on = [
    garage_bucket.bucket
  ]
}
