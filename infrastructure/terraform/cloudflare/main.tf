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
      version = "3.27.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "cloudflare_secrets" {
  source_file = "cloudflare_secrets.sops.yaml"
}

data "http" "bjws_common_domains" {
  url = "${local.cloudflare_secrets.s3.server}/bjws-common/domains.yaml"
}

# Obtain current home IP address
data "http" "ipv4_lookup_raw" {
  url = "http://ipv4.icanhazip.com"
}
