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
  issue_labels = [
    { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
    { name = "area/kubernetes", color = "72ccf3", description = "Issue relates to Kubernetes" },

    { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
    { name = "renovate/helm", color = "ffc300", description = "Issue relates to a Renovate helm update" },

    { name = "type/patch", color = "ffec19", description = "Issue relates to a patch version bump" },
    { name = "type/minor", color = "ff9800", description = "Issue relates to a minor version bump" },
    { name = "type/major", color = "f6412d", description = "Issue relates to a major version bump" },

    { name = "size/XS", color = "009900", description = "Marks a PR that changes 0-9 lines, ignoring generated files" },
    { name = "size/S", color = "77bb00", description = "Marks a PR that changes 10-29 lines, ignoring generated files" },
    { name = "size/M", color = "eebb00", description = "Marks a PR that changes 30-99 lines, ignoring generated files" },
    { name = "size/L", color = "ee9900", description = "Marks a PR that changes 100-499 lines, ignoring generated files" },
    { name = "size/XL", color = "ee5500", description = "Marks a PR that changes 500-999 lines, ignoring generated files" },
    { name = "size/XXL", color = "ee0000", description = "Marks PR that changes 1000+ lines, ignoring generated files" },

    { name = "bug", color = "d73a4a", description = "Something isn't working" },
    { name = "documentation", color = "0075ca", description = "Improvements or additions to documentation" },
    { name = "enhancement", color = "a2eeef", description = "New feature or request" },
    { name = "question", color = "d876e3", description = "Further information is requested" },
    { name = "wontfix", color = "ffffff", description = "This will not be worked on" },
    { name = "do-not-merge", color = "ee0701", description = "Marks PR that is not (yet) in a mergeable state" }
  ]

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
}
