module "minio_bucket_thanos" {
  source      = "./minio_bucket"
  bucket_name = "thanos"
  providers = {
    minio = minio.nas
  }
}

module "minio_bucket_loki" {
  source      = "./minio_bucket"
  bucket_name = "loki"
  providers = {
    minio = minio.nas
  }
}

module "minio_bucket_postgresql" {
  source      = "./minio_bucket"
  bucket_name = "postgresql"
  providers = {
    minio = minio.nas
  }
}
