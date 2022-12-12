terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "home-fly-provisioner"
    }
  }

  required_providers {
    fly = {
      source  = "fly-apps/fly"
      version = "0.0.20"
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

data "sops_file" "fly_secrets" {
  source_file = "fly_secrets.sops.yaml"
}

data "http" "bjws_common_domains" {
  url = "https://raw.githubusercontent.com/bjw-s/home-ops/main/infrastructure/_shared/domains.sops.yaml"
}

data "sops_external" "domains" {
  source     = data.http.bjws_common_domains.response_body
  input_type = "yaml"
}

provider "fly" {
  fly_api_token        = local.fly_secrets["fly_api_token"]
  useinternaltunnel    = true
  internaltunnelorg    = "personal"
  internaltunnelregion = "ams"
}

module "gatus" {
  providers = {
    fly = fly
  }
  source = "./modules/gatus"

  secrets = local.fly_secrets
  domains = local.domains
  regions = ["ams"]
}
