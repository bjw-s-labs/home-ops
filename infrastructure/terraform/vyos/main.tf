terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "home-vyos-provisioner"
    }
  }

  required_providers {
    vyos = {
      source  = "Foltik/vyos"
      version = "0.3.3"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }

    remote = {
      source  = "tenstad/remote"
      version = "0.1.1"
    }
  }
}

data "sops_file" "vyos_secrets" {
  source_file = "vyos_secrets.sops.yaml"
}

data "http" "bjws_common_domains" {
  url = "${local.vyos_secrets.s3.server}/bjws-common/domains.yaml"
}

data "http" "bjws_common_address_book" {
  url = "${local.vyos_secrets.s3.server}/bjws-common/address_book.yaml"
}

data "http" "bjws_common_networks" {
  url = "${local.vyos_secrets.s3.server}/bjws-common/networks.yaml"
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
