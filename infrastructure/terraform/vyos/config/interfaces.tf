resource "vyos_config_block_tree" "interface-wan" {
  path = "interfaces ethernet ${var.config.zones.wan.interface}"
  configs = {
    "address"     = "dhcp"
    "description" = "WAN"
    "hw-id"       = "00:f4:21:68:3e:9c"
  }
}

resource "vyos_config_block_tree" "interface-lan" {
  path = "interfaces ethernet ${var.config.zones.lan.interface}"
  configs = {
    "address"     = "${cidrhost(var.networks.lan, 1)}/24"
    "description" = "LAN"
    "hw-id"       = "00:f4:21:68:3e:9d"

    "vif 10 description" = "SERVERS"
    "vif 10 address"     = "${cidrhost(var.networks.servers, 1)}/24"
    "vif 20 description" = "TRUSTED"
    "vif 20 address"     = "${cidrhost(var.networks.trusted, 1)}/24"
    "vif 30 description" = "GUEST"
    "vif 30 address"     = "${cidrhost(var.networks.guest, 1)}/24"
    "vif 40 description" = "IOT"
    "vif 40 address"     = "${cidrhost(var.networks.iot, 1)}/24"
    "vif 50 description" = "VIDEO"
    "vif 50 address"     = "${cidrhost(var.networks.video, 1)}/24"
  }
}

resource "vyos_config_block_tree" "interface-rescue" {
  path = "interfaces ethernet ${var.config.zones.rescue.interface}"
  configs = {
    "address"     = "${cidrhost(var.networks.rescue, 1)}/24"
    "description" = "RESCUE"
    "hw-id"       = "00:f4:21:68:3e:9e"
  }
}

resource "vyos_config_block_tree" "interface-wireguard" {
  path = "interfaces wireguard ${var.config.zones.wg_trusted.interface}"
  configs = merge(
    {
      "address"     = "${cidrhost(var.networks.wg_trusted, 1)}/24"
      "description" = "WIREGUARD"
      "port"        = "${var.config.zones.wg_trusted.port}"
      "private-key" = "${var.config.zones.wg_trusted.private_key}"
    },

    merge(flatten([
      for peer, peer_config in var.config.zones.wg_trusted.peers : {
        "peer ${peer} allowed-ips"          = "${cidrhost(var.networks.wg_trusted, peer_config.ipv4_hostid)}/32"
        "peer ${peer} public-key"           = "${peer_config.public_key}"
        "peer ${peer} persistent-keepalive" = "15"
      }
    ])...),
  )
}
