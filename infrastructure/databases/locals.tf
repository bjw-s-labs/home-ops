locals {
  domains = yamldecode(nonsensitive(data.sops_file.domains.raw))
}
