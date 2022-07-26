module "home-ops" {
  source  = "mineiros-io/repository/github"
  version = "0.16.2"

  name         = "home-ops"
  description  = "My home or for-home infrastructure written as code, adhering to GitOps practices"
  topics       = ["flux", "gitops", "iac", "k8s-at-home", "kubernetes", "renovate"]
  homepage_url = "https://bjw-s.github.io/home-ops"
  visibility   = "public"

  auto_init              = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  plaintext_secrets = {
    "BJWS_APP_ID"          = data.sops_file.github_secrets.data["apps.bjws_bot.app_id"]
    "BJWS_APP_PRIVATE_KEY" = data.sops_file.github_secrets.data["apps.bjws_bot.private_key"]
  }

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/kubernetes", color = "72ccf3", description = "Issue relates to Kubernetes" },

      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
      { name = "renovate/helm", color = "ffc300", description = "Issue relates to a Renovate helm update" },
    ],
    local.default_issue_labels
  )

  pages = {
    custom_404 = true
    html_url   = "https://bjw-s.github.io/home-ops/"
    status     = "built"
    url        = "https://api.github.com/repos/bjw-s/home-ops/pages"
    branch     = "gh-pages"
    path       = "/"
  }

  webhooks = [
    {
      events       = ["push"]
      url          = data.sops_file.github_secrets.data["home_ops.webhook.url"]
      active       = true
      content_type = "json"
      secret       = data.sops_file.github_secrets.data["home_ops.webhook.secret"]
    }
  ]
}

module "pmb" {
  source  = "mineiros-io/repository/github"
  version = "0.16.2"

  name        = "pmb"
  description = "Poor Man's Backup"
  topics      = ["kubernetes", "docker", "backups", "sidecar"]
  visibility  = "public"

  auto_init              = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  plaintext_secrets = {
    "BJWS_APP_ID"          = data.sops_file.github_secrets.data["apps.bjws_bot.app_id"]
    "BJWS_APP_PRIVATE_KEY" = data.sops_file.github_secrets.data["apps.bjws_bot.private_key"]
  }

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "renovate-config" {
  source  = "mineiros-io/repository/github"
  version = "0.16.2"

  name        = "renovate-config"
  description = "Renovate configuration presets"
  topics      = ["renovate", "gitops", "ci"]
  visibility  = "public"

  auto_init              = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  plaintext_secrets = {
    "BJWS_APP_ID"          = data.sops_file.github_secrets.data["apps.bjws_bot.app_id"]
    "BJWS_APP_PRIVATE_KEY" = data.sops_file.github_secrets.data["apps.bjws_bot.private_key"]
  }

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "library-charts" {
  source  = "mineiros-io/repository/github"
  version = "0.16.2"

  name        = "library-charts"
  description = "Helm library charts"
  topics      = ["helm", "kubernetes"]
  visibility  = "public"

  auto_init              = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  plaintext_secrets = {
    "BJWS_APP_ID"          = data.sops_file.github_secrets.data["apps.bjws_bot.app_id"]
    "BJWS_APP_PRIVATE_KEY" = data.sops_file.github_secrets.data["apps.bjws_bot.private_key"]
  }

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )

  push_collaborators = [
    "onedr0p"
  ]
}
