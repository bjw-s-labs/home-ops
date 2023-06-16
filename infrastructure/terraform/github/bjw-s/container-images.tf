module "container_images" {
  source = "github.com/bjw-s/terraform-github-repository?ref=v1.1.0"

  name        = "container-images"
  description = "Kubernetes tailored container images for various applications"
  topics      = ["kubernetes", "docker", "containers"]
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
    {
      "BJWS_DISCORD_WEBHOOK" : var.secrets.discord_ci_webhook_url
    },
    local.bjws_bot_secrets
  )

  issue_labels_manage_default_github_labels = false
  issue_labels = concat(
    [],
    local.issue_labels_semver,
    local.issue_labels_category
  )
}
