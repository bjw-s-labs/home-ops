module "home_ops" {
  source = "github.com/bjw-s/terraform-github-repository?ref=v1.0.1"

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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_manage_default_github_labels = false
  issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/kubernetes", color = "72ccf3", description = "Issue relates to Kubernetes" },

      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
      { name = "renovate/helm", color = "ffc300", description = "Issue relates to a Renovate helm update" },
    ],
    local.issue_labels_semver,
    local.issue_labels_size,
    local.issue_labels_category
  )

  pages = {
    build_type = "legacy"
    branch     = "gh-pages"
    path       = "/"
  }

  webhooks = [
    {
      events = ["push"]
      url    = nonsensitive(var.secrets.flux_github_webhook_url)
      secret = var.secrets.flux_github_webhook_secret
    }
  ]
}
