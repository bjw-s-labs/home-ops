terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
    }
  }
}

resource "minio_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = var.is_public == true ? "public" : "private"
}

resource "minio_iam_user" "user" {
  name          = var.owner_access_key != null ? var.owner_access_key : var.bucket_name
  force_destroy = true
  secret        = var.owner_secret_key != null ? var.owner_secret_key : null
}

resource "minio_iam_policy" "rw_policy" {
  name   = "${var.bucket_name}-rw"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}",
                "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}/*"
            ],
            "Sid": ""
        }
    ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "user_rw" {
  user_name   = minio_iam_user.user.id
  policy_name = minio_iam_policy.rw_policy.id
}
