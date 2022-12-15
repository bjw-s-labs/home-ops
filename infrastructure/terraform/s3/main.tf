terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.1"
    }
    minio = {
      source  = "aminueza/minio"
      version = "1.10.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
    onepassword = {
      source = "1Password/onepassword"
      version = "1.1.4"
    }
  }
}

data "sops_file" "s3_secrets" {
  source_file = "s3_secrets.sops.yaml"
}
