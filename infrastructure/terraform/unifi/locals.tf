locals {
  domains      = yamldecode(nonsensitive(data.sops_file.domains.raw))
  networks     = yamldecode(file(pathexpand("${path.module}/../../networks.yaml")))
}
