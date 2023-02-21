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

module "onepassword_item_vyos" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Automation"
  item   = "vyos"
}

module "onepassword_item_cloudflare" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Services"
  item   = "Cloudflare"
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
  secrets = {
    cloudflare_dyndns_login = module.onepassword_item_cloudflare.fields.username
    cloudflare_dyndns_token = module.onepassword_item_cloudflare.fields.api-key
    terraform_api_key       = module.onepassword_item_vyos.fields.api_key
    vyos_password           = module.onepassword_item_vyos.fields.password
    wireguard_private_key   = module.onepassword_item_vyos.fields.wireguard_private_key
  }

  providers = {
    vyos   = vyos.vyos
    remote = remote.vyos
  }
}
