module "esphome_config" {
  source = "github.com/bjw-s/terraform-github-repository?ref=v1.2.0"

  name        = "esphome-config"
  description = "My ESPHome configs."
  topics      = ["esphome", "esphome-devices", "esphome-config", "home-assistant"]
  visibility  = "public"

  auto_init              = var.defaults.auto_init
  allow_merge_commit     = var.defaults.allow_merge_commit
  allow_squash_merge     = var.defaults.allow_squash_merge
  allow_auto_merge       = var.defaults.allow_auto_merge
  delete_branch_on_merge = var.defaults.delete_branch_on_merge

  squash_merge_commit_message = var.defaults.squash_merge_commit_message

  has_issues   = var.defaults.has_issues
  has_wiki     = var.defaults.has_wiki
  has_projects = var.defaults.has_projects

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
