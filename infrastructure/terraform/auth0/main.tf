terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "home-auth0-provisioner"
    }
  }

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "0.40.0"
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

data "sops_file" "auth0_secrets" {
  source_file = "auth0_secrets.sops.yaml"
}

data "http" "bjws_common_domains" {
  url = "https://raw.githubusercontent.com/bjw-s/home-ops/main/infrastructure/_shared/domains.sops.yaml"
}

data "sops_external" "domains" {
  source     = data.http.bjws_common_domains.response_body
  input_type = "yaml"
}

module "bjws" {
  source = "./modules/bjws"

  domains = local.domains
  secrets = local.auth0_secrets
}
