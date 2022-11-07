locals {
  domains   = yamldecode(data.sops_file.domains.raw)
  home_ipv4 = chomp(data.http.ipv4_lookup_raw.response_body)
}
