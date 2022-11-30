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
      version = "3.29.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
  }
}

data "sops_file" "cloudflare_secrets" {
  source_file = "cloudflare_secrets.sops.yaml"
}

data "http" "bjws_common_domains" {
  url = "https://raw.githubusercontent.com/bjw-s/home-ops/main/infrastructure/_shared/domains.sops.yaml"
}

data "sops_external" "domains" {
  source     = data.http.bjws_common_domains.response_body
  input_type = "yaml"
}

# Obtain current home IP address
data "http" "ipv4_lookup_raw" {
  url = "http://ipv4.icanhazip.com"
}
