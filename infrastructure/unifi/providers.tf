provider "unifi" {
  alias = "unifi"

  username = data.sops_file.unifi_secrets.data["unifi.username"]
  password = data.sops_file.unifi_secrets.data["unifi.password"]
  api_url  = data.sops_file.unifi_secrets.data["unifi.url"]
}
