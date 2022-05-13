provider "vyos" {
  url = data.sops_file.vyos_secrets.data["api.url"]
  key = data.sops_file.vyos_secrets.data["api.key"]
}
