resource "remote_file" "container-adguard-home-dummyhosts" {
  provider    = remote
  path        = "/config/adguard-home/hosts"
  content     = ""
  permissions = "0644"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "vyos_config_block_tree" "container-adguard-home" {
  path = "container name adguard-home"

  configs = {
    "image" = "${var.config.containers.adguard-home.image}"

    "network services address" = "${cidrhost(var.networks.services, 6)}"

    "volume hosts destination"   = "/etc/hosts"
    "volume hosts source"        = "/config/adguard-home/hosts"
    "volume config destination"  = "/opt/adguardhome/conf"
    "volume config source"       = "/config/adguard-home/conf"
    "volume workdir destination" = "/opt/adguardhome/work"
    "volume workdir source"      = "/config/adguard-home/work"
  }

  depends_on = [
    vyos_config_block_tree.container_network-services,
    remote_file.container-adguard-home-dummyhosts
  ]
}
