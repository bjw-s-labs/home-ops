module "dotfiles" {
  source = "github.com/bjw-s/terraform-github-repository?ref=v1.1.0"

  name        = "dotfiles"
  description = "My collection of dotfiles, powered by chezmoi"
  topics      = ["dotfiles", "macos", "chezmoi"]
  visibility  = "public"

  archived = false

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
