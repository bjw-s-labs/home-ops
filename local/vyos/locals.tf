locals {
  config = {
    hostname             = "gateway"
    domain_name          = data.sops_file.vyos_secrets.data["domain_name"]
    upstream_name_server = "1.1.1.1"
    time_zone            = "Europe/Amsterdam"

    api = {
      listen_address = "0.0.0.0"
      port           = 8443
      keys = {
        terraform = data.sops_file.vyos_secrets.data["api.key"]
      }
    }

    ssh = {
      port                   = 22
      disable_password_login = true
      keys                   = yamldecode(data.sops_file.vyos_secrets.raw).ssh.keys
    }
  }
}
