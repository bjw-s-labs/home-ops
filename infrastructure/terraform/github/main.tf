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
      version = "5.31.0"
    }
  }
}

module "onepassword_item_github" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Services"
  item   = "Github"
}

module "onepassword_item_github_bjws_bot" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Automation"
  item   = "github-bjws-bot"
}

module "onepassword_item_flux" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Automation"
  item   = "flux"
}

module "onepassword_item_discord" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Services"
  item   = "Discord"
}

module "bjw-s" {
  source = "./bjw-s"

  secrets = {
    bjws_bot_app_id            = module.onepassword_item_github_bjws_bot.fields.github_app_id
    bjws_bot_private_key       = module.onepassword_item_github_bjws_bot.fields.github_app_private_key
    flux_github_webhook_url    = module.onepassword_item_flux.fields.github_webhook_url
    flux_github_webhook_secret = module.onepassword_item_flux.fields.github_webhook_token
    discord_ci_webhook_url     = module.onepassword_item_discord.fields.webhook_bjws_github_ci
  }
}

moved {
  from = module.vyos-config
  to   = module.bjw-s.module.vyos_config
}

moved {
  from = module.terraform-1password-item
  to   = module.bjw-s.module.terraform_1password_item
}

moved {
  from = module.gh-workflows
  to   = module.bjw-s.module.gh_workflows
}

moved {
  from = module.helm-charts
  to   = module.bjw-s.module.helm_charts
}

moved {
  from = module.home-ops
  to   = module.bjw-s.module.home_ops
}
