terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "home-cloudflare-provisioner"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.10.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.6.3"
    }
  }
}

data "sops_file" "cloudflare_secrets" {
  source_file = "secret.sops.yaml"
}
