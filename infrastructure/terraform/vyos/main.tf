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
  source_file = "secret.sops.yaml"
}

data "sops_file" "domains" {
  source_file = pathexpand("${path.module}/../../domains.sops.yaml")
}

data "sops_file" "address_book" {
  source_file = pathexpand("${path.module}/../../address_book.sops.yaml")
}

module "config" {
  source = "./config"

  config         = local.config
  networks       = local.networks
  domains        = local.domains
  address_book   = local.address_book
  firewall_rules = local.firewall_rules
  secrets        = sensitive(yamldecode(nonsensitive(data.sops_file.vyos_secrets.raw)))

  providers = {
    vyos   = vyos.vyos
    remote = remote.vyos
  }
}
