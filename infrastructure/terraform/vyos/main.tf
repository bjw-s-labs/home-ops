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
      version = "1.1.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
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

data "http" "bjws_common_domains" {
  url = "https://raw.githubusercontent.com/bjw-s/home-ops/main/infrastructure/_shared/domains.sops.yaml"
}

data "sops_external" "domains" {
  source     = data.http.bjws_common_domains.response_body
  input_type = "yaml"
}

data "sops_file" "address_book" {
  source_file = "address_book.sops.yaml"
}

data "http" "bjws_common_networks" {
  url = "https://raw.githubusercontent.com/bjw-s/home-ops/main/infrastructure/_shared/networks.yaml"
}

module "config" {
  source = "./modules/config"

  config         = local.config
  networks       = local.networks
  domains        = local.domains
  address_book   = local.address_book
  firewall_rules = local.firewall_rules
  secrets        = local.vyos_secrets

  providers = {
    vyos   = vyos.vyos
    remote = remote.vyos
  }
}
