locals {
  auth0_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.auth0_secrets.raw)))
}
