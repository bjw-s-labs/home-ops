resource "remote_file" "container-adguard-home-dummyhosts" {
  provider    = remote
  path        = "/config/adguard-home/hosts"
  content     = ""
  permissions = "0775"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "vyos_config" "container-adguard-home" {
  path = "container name adguard-home"
  value = jsonencode({
    "image" = "${var.config.containers.adguard-home.image}"
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 6)}"
      }
    }
    "volume" = {
      "hosts" = {
        "source"      = "/config/adguard-home/hosts"
        "destination" = "/etc/hosts"
      }
      "config" = {
        "source"      = "/config/adguard-home/conf"
        "destination" = "/opt/adguardhome/conf"
      }
      "workdir" = {
        "source"      = "/config/adguard-home/work"
        "destination" = "/opt/adguardhome/work"
      }
    }
  })

  depends_on = [
    vyos_config.container_network-services,
    remote_file.container-adguard-home-dummyhosts
  ]
}
