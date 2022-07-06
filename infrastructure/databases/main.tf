terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "home-database-provisioner"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.16.0"
    }
  }
}

data "sops_file" "database_secrets" {
  source_file = "secret.sops.yaml"
}

data "sops_file" "domains" {
  source_file = pathexpand("${path.module}/../domains.sops.yaml")
}
