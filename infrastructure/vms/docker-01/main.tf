terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "vms-docker-01"
    }
  }

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.11.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "vm_secrets" {
  source_file = "secret.sops.yaml"
}

data "sops_file" "domains" {
  source_file = pathexpand("${path.module}/../../domains.sops.yaml")
}
