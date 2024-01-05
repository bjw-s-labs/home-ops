terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.8"
    }

    minio = {
      source = "aminueza/minio"
      version = "2.0.1"
    }
  }
}
