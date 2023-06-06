module "home-ops" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

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
      url          = module.onepassword_item_flux.fields.github_webhook_url
      active       = true
      content_type = "json"
      secret       = module.onepassword_item_flux.fields.github_webhook_token
    }
  ]
}

module "pmb" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "pmb"
  description = "Poor Man's Backup"
  topics      = ["kubernetes", "docker", "backups", "sidecar"]
  visibility  = "public"

  archived = true

  auto_init              = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "renovate-config" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "helm-charts" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

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
  is_template  = false

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
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

  push_collaborators = [
    "onedr0p"
  ]

  pages = {
    custom_404 = true
    html_url   = "https://bjw-s.github.io/helm-charts/"
    status     = "built"
    url        = "https://api.github.com/repos/bjw-s/helm-charts/pages"
    branch     = "gh-pages"
    path       = "/"
  }
}

module "container-images" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

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
  is_template  = false

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "helm-charts-actions" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

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
  is_template  = false

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "gh-workflows" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "gh-workflows"
  description = "A collection of reusable GitHub workflows"
  topics      = ["ci", "github", "workflows"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "klipper-config" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "klipper-config"
  description = "My Klipper configurations"
  topics      = ["3dprinter", "klipper"]
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

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "esphome-config" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "esphome-config"
  description = "My ESPHome configs."
  topics      = ["esphome", "esphome-devices", "esphome-config", "home-assistant"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "terraform-1password-item" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "terraform-1password-item"
  description = "Terraform Module that collects all fields for a 1Password Item."
  topics      = ["terraform", "1password"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "series-cleanup" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "series-cleanup"
  description = "Script to periodically clean media files from disk"
  topics      = ["media", "golang", "trakt"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "vyos-config" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "vyos-config"
  description = "My VyOS configuration"
  topics      = ["vyos", "iac"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "kobomail" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "KoboMail"
  description = "Experimental email attachment downloader for Kobo devices"
  topics      = ["kobo", "mail", "golang"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "asdf_krew" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "asdf-krew"
  description = "krew plugin for the asdf version manager"
  topics      = ["asdf", "krew", "kubectl", "asdf-plugin"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "asdf_talosctl" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "asdf-talosctl"
  description = "talosctl plugin for the asdf version manager"
  topics      = ["asdf", "talos", "talosctl", "asdf-plugin"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "asdf_talhelper" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "asdf-talhelper"
  description = "talhelper plugin for the asdf version manager"
  topics      = ["asdf", "talos", "talhelper", "asdf-plugin"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "asdf_revive" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "asdf-revive"
  description = "revive plugin for the asdf version manager"
  topics      = ["asdf", "golang", "revive", "asdf-plugin"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "dotfiles" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

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
  is_template  = false

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}

module "helm3_unittest" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "helm3-unittest"
  description = "Fork of lrills/helm-unittest but for Helm 3"
  topics      = ["helm", "unittest", "golang"]
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

  plaintext_secrets = merge(
    {},
    local.bjws_bot_secrets
  )

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [],
    local.default_issue_labels
  )
}
