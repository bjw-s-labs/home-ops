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
      version = "0.38.2"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "unifi_secrets" {
  source_file = "unifi_secrets.sops.yaml"
}

data "http" "bjws_common_domains" {
  url = "https://raw.githubusercontent.com/bjw-s/home-ops/main/infrastructure/_shared/domains.sops.yaml"
}

data "sops_external" "domains" {
  source     = data.http.bjws_common_domains.response_body
  input_type = "yaml"
}

module "config" {
  source = "./modules/config"

  networks = local.networks
  domains  = local.domains
  secrets  = sensitive(yamldecode(nonsensitive(data.sops_file.unifi_secrets.raw)))

  providers = {
    unifi = unifi.unifi
  }
}
