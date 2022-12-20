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
      version = "0.41.0"
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

module "bjws" {
  source = "./modules/bjws"

  secrets = local.auth0_secrets
}
