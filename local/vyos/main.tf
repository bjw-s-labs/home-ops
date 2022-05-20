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
      version = "0.3.2"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.6.3"
    }

    remote = {
      source  = "tenstad/remote"
      version = "0.0.24"
    }
  }
}

data "sops_file" "vyos_secrets" {
  source_file = "secret.sops.yaml"
}

module "config" {
  source = "./config"

  config = local.config

  providers = {
    vyos   = vyos.vyos
    remote = remote.vyos
  }
}
