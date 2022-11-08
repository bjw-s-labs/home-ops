locals {
  cloudflare_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.cloudflare_secrets.raw)))
  domains            = yamldecode(nonsensitive(data.sops_external.domains.raw))
  home_ipv4          = chomp(data.http.ipv4_lookup_raw.response_body)
}
