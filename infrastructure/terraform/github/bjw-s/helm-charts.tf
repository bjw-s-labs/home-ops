module "helm_charts" {
  source = "github.com/bjw-s/terraform-github-repository?ref=v1.0.1"

  name         = "helm-charts"
  description  = "A collection of Helm charts"
  topics       = ["helm", "kubernetes"]
  homepage_url = "https://bjw-s.github.io/helm-charts/"
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
    [],
    local.issue_labels_semver,
    local.issue_labels_size,
    local.issue_labels_category
  )

  branches = [
    {
      name          = "development"
      source_branch = "main"
    },
    {
      name = "gh-pages"
    }
  ]

  collaborators = [
    {
      username   = "onedr0p"
      permission = "push"
    }
  ]

  pages = {
    build_type = "legacy"
    branch     = "gh-pages"
    path       = "/"
  }
}
