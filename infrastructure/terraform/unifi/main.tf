terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "home-unifi-provisioner"
    }
  }

  required_providers {
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.3.0"
    }
  }
}

data "http" "bjws_common_networks" {
  url = "https://raw.githubusercontent.com/bjw-s/home-ops/main/infrastructure/_shared/networks.yaml"
}

module "onepassword_item_unifi_controller" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Services"
  item   = "Unifi Controller"
}

module "config" {
  source = "./modules/config"

  networks = local.networks

  providers = {
    unifi = unifi.home
  }
}
