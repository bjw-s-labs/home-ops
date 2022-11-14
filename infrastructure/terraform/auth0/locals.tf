locals {
  auth0_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.auth0_secrets.raw)))
  domains       = yamldecode(nonsensitive(data.sops_external.domains.raw))
}
