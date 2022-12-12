locals {
  fly_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.fly_secrets.raw)))
  domains     = yamldecode(nonsensitive(data.sops_external.domains.raw))
}
