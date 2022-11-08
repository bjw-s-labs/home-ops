locals {
  domains  = yamldecode(nonsensitive(data.sops_external.domains.raw))
  networks       = yamldecode(chomp(data.http.bjws_common_networks.response_body))
}
