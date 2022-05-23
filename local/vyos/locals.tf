locals {
  _config = yamldecode(
      templatefile(
        "settings.yaml",
        {secrets = nonsensitive(yamldecode(data.sops_file.vyos_secrets.raw))}
      )
    )

  config = local._config.config
  networks = local._config.networks
}
