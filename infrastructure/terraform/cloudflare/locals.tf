locals {
  cloudflare_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.cloudflare_secrets.raw)))
  home_ipv4          = chomp(data.http.ipv4_lookup_raw.response_body)
}
