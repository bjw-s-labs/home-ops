terraform {
  cloud {
    organization = "bjw-s"
    workspaces {
      name = "home-github-provisioner"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.9.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "github_secrets" {
  source_file = "github_secrets.sops.yaml"
}
