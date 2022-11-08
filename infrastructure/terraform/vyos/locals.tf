locals {
  _config = yamldecode(
    templatefile(
      "settings.yaml",
      {
        address_book = local.address_book
        domains      = local.domains
        networks     = local.networks
        secrets      = yamldecode(nonsensitive(data.sops_file.vyos_secrets.raw))
      }
    )
  )

  domains        = yamldecode(chomp(data.http.bjws_common_domains.response_body))
  networks       = yamldecode(chomp(data.http.bjws_common_networks.response_body))
  address_book   = yamldecode(chomp(data.http.bjws_common_address_book.response_body))
  firewall_rules = yamldecode(file(pathexpand("${path.module}/firewall_rules.yaml")))

  config = local._config.config
  vyos_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.vyos_secrets.raw)))
}
