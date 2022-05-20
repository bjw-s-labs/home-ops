provider "vyos" {
  alias = "vyos"

  url = data.sops_file.vyos_secrets.data["api.url"]
  key = data.sops_file.vyos_secrets.data["api.key"]
}

provider "remote" {
  alias = "vyos"

  max_sessions = 2

  conn {
    host             = data.sops_file.vyos_secrets.data["ssh.host"]
    port             = 22
    user             = data.sops_file.vyos_secrets.data["ssh.user"]
    private_key_path = pathexpand("~/.ssh/identities/personal/id_personal")

    sudo = true
  }
}
