module "helm_charts_actions" {
  source = "github.com/bjw-s/terraform-github-repository?ref=v1.0.1"

  name        = "helm-charts-actions"
  description = "A collection of GitHub actions to use with helm-charts repo"
  topics      = ["helm", "github-actions"]
  visibility  = "public"

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
    local.issue_labels_category
  )
}
