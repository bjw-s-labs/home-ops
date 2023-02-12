terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "home-vyos-provisioner"
    }
  }

  required_providers {
    vyos = {
      source  = "TGNThump/vyos"
      version = "2.0.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.1.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
  }
}

data "sops_file" "vyos_secrets" {
  source_file = "vyos_secrets.sops.yaml"
}

data "http" "bjws_common_networks" {
  url = "https://raw.githubusercontent.com/bjw-s/home-ops/main/infrastructure/_shared/networks.yaml"
}

module "config" {
  source = "./modules/config"

  config         = local.config
  networks       = local.networks
  address_book   = local.address_book
  firewall_rules = local.firewall_rules
  secrets        = local.vyos_secrets

  providers = {
    vyos   = vyos.vyos
    remote = remote.vyos
  }
}
