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

  domains      = yamldecode(nonsensitive(data.sops_file.domains.raw))
  networks     = yamldecode(file(pathexpand("${path.module}/../networks.yaml")))
  address_book = yamldecode(file(pathexpand("${path.module}/../address_book.yaml")))

  config = local._config.config
}
