provider "vyos" {
  alias = "vyos"

  url = "https://${local.config.fqdn}:${local.config.api.port}"
  key = data.sops_file.vyos_secrets.data["api.key"]
}

provider "remote" {
  alias = "vyos"

  max_sessions = 2

  conn {
    host             = local.config.fqdn
    port             = local.config.ssh.port
    user             = local.config.ssh.user
    private_key_path = pathexpand("~/.ssh/identities/personal/id_personal")

    sudo = true
  }
}
