resource "github_repository" "home_ops" {
  name        = "home-ops"
  description = "My home or for-home infrastructure written as code, adhering to GitOps practices"
  topics = [
    "k8s-at-home",
    "kubernetes",
    "flux",
    "gitops",
    "renovate"
  ]

  visibility = "public"

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_rebase_merge     = true
  allow_squash_merge     = true
  delete_branch_on_merge = true

  homepage_url = "https://bjw-s.github.io/home-ops"
  pages {
    source {
      branch = "gh-pages"
      path   = "/"
    }
  }
}

resource "github_repository_environment" "home_ops_gh_pages" {
  environment = "github-pages"
  repository  = github_repository.home_ops.name

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment" "home_ops_production" {
  environment = "production"
  repository  = github_repository.home_ops.name

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_actions_secret" "home_ops_bjws_bot_app_id" {
  repository      = github_repository.home_ops.name
  secret_name     = "BJWS_APP_ID"
  plaintext_value = data.sops_file.github_secrets.data["apps.bjws_bot.app_id"]
}

resource "github_actions_secret" "home_ops_bjws_bot_app_key" {
  repository      = github_repository.home_ops.name
  secret_name     = "BJWS_APP_PRIVATE_KEY"
  plaintext_value = data.sops_file.github_secrets.data["apps.bjws_bot.private_key"]
}

resource "github_actions_secret" "home_ops_terraform_token" {
  repository  = github_repository.home_ops.name
  secret_name = "TF_CLOUD_TOKEN"
}

resource "github_actions_environment_secret" "home_ops_production_terraform_token" {
  repository  = github_repository.home_ops.name
  environment = github_repository_environment.home_ops_production.environment
  secret_name = "TF_CLOUD_TOKEN"
}

resource "github_repository_webhook" "home_ops_flux" {
  repository = github_repository.home_ops.name
  active     = true
  events     = ["push"]

  configuration {
    url          = data.sops_file.github_secrets.data["home_ops.webhook.url"]
    content_type = "json"
    secret       = data.sops_file.github_secrets.data["home_ops.webhook.secret"]
    insecure_ssl = false
  }

}
