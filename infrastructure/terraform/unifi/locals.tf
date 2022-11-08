locals {
  domains  = yamldecode(nonsensitive(data.sops_external.domains.raw))
  networks = yamldecode(file(pathexpand("${path.module}/../../networks.yaml")))
}
