locals {
  cloudflare_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.cloudflare_secrets.raw)))
  domains   = yamldecode(chomp(data.http.bjws_common_domains.response_body))
  home_ipv4 = chomp(data.http.ipv4_lookup_raw.response_body)
}
