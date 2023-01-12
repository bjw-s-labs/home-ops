module "home-ops" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "pmb" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "renovate-config" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "helm-charts" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "container-images" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "helm-charts-actions" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "gh-workflows" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "klipper-config" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "esphome-config" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}

module "terraform-1password-item" {
  source = "github.com/bjw-s/terraform-github-repository.git?ref=main"

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

  security_and_analysis = {
    advanced_security = "enabled"
  }
}
