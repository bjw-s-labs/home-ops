locals {
  settings = yamldecode(
    file("settings.yaml")
  )
  domains = yamldecode(nonsensitive(data.sops_file.domains.raw))
}
