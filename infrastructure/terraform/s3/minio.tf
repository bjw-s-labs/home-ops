module "minio_bucket_thanos" {
  source      = "./modules/minio_bucket"
  bucket_name = "thanos"
  providers = {
    minio = minio.nas
  }
}

module "minio_bucket_loki" {
  source      = "./modules/minio_bucket"
  bucket_name = "loki"
  providers = {
    minio = minio.nas
  }
}

module "minio_bucket_postgresql" {
  source      = "./modules/minio_bucket"
  bucket_name = "postgresql"
  providers = {
    minio = minio.nas
  }
}

resource "minio_s3_bucket" "bjws_common" {
  provider = minio.nas
  bucket   = "bjws-common"
  acl      = "public"
}

data "sops_file" "address_book" {
  source_file = "data/address_book.sops.yaml"
}

data "sops_file" "domains" {
  source_file = "data/domains.sops.yaml"
}

resource "minio_s3_object" "bjws_common_address_book" {
  depends_on = [
    data.sops_file.address_book,
    minio_s3_bucket.bjws_common
  ]
  provider     = minio.nas
  bucket_name  = minio_s3_bucket.bjws_common.bucket
  object_name  = "address_book.yaml"
  content      = data.sops_file.address_book.raw
  content_type = "text/yaml"
}

resource "minio_s3_object" "bjws_common_domains" {
  depends_on = [
    data.sops_file.domains,
    minio_s3_bucket.bjws_common
  ]
  provider     = minio.nas
  bucket_name  = minio_s3_bucket.bjws_common.bucket
  object_name  = "domains.yaml"
  content      = data.sops_file.domains.raw
  content_type = "text/yaml"
}

resource "minio_s3_object" "bjws_common_networks" {
  depends_on = [
    minio_s3_bucket.bjws_common
  ]
  provider     = minio.nas
  bucket_name  = minio_s3_bucket.bjws_common.bucket
  object_name  = "networks.yaml"
  content      = file("data/networks.yaml")
  content_type = "text/yaml"
}
