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
      version = "0.38.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "unifi_secrets" {
  source_file = "secret.sops.yaml"
}

data "sops_file" "domains" {
  source_file = pathexpand("${path.module}/../domains.sops.yaml")
}

data "sops_file" "address_book" {
  source_file = pathexpand("${path.module}/../address_book.sops.yaml")
}

module "config" {
  source = "./config"

  networks     = local.networks
  domains      = local.domains
  address_book = local.address_book
  secrets      = sensitive(yamldecode(nonsensitive(data.sops_file.unifi_secrets.raw)))

  providers = {
    unifi = unifi.unifi
  }
}
