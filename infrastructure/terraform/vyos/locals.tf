locals {
  _config = yamldecode(
    templatefile(
      "settings.yaml",
      {
        address_book = local.address_book
        networks     = local.networks
        secrets      = yamldecode(nonsensitive(data.sops_file.vyos_secrets.raw))
      }
    )
  )

  networks       = yamldecode(chomp(data.http.bjws_common_networks.response_body))
  address_book   = yamldecode(file(pathexpand("${path.module}/address_book.yaml")))
  firewall_rules = yamldecode(file(pathexpand("${path.module}/firewall_rules.yaml")))

  config       = local._config.config
  vyos_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.vyos_secrets.raw)))
}
