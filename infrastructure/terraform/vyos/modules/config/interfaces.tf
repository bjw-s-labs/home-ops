resource "vyos_config" "interface-wan" {
  path = "interfaces ethernet ${var.config.zones.wan.interface}"
  value = jsonencode({
    "address"     = "dhcp"
    "description" = "WAN"
    "hw-id"       = "00:f4:21:68:3e:9c"
  })
}

resource "vyos_config" "interface-lan" {
  path = "interfaces ethernet ${var.config.zones.lan.interface}"
  value = jsonencode({
    "address"     = "${cidrhost(var.networks.lan, 1)}/24"
    "description" = "LAN"
    "hw-id"       = "00:f4:21:68:3e:9d"
    "vif" = {
      "10" = {
        "description" = "SERVERS"
        "address"     = "${cidrhost(var.networks.servers, 1)}/24"
      }
      "20" = {
        "description" = "TRUSTED"
        "address"     = "${cidrhost(var.networks.trusted, 1)}/24"
      }
      "30" = {
        "description" = "GUEST"
        "address"     = "${cidrhost(var.networks.guest, 1)}/24"
      }
      "40" = {
        "description" = "IOT"
        "address"     = "${cidrhost(var.networks.iot, 1)}/24"
      }
      "50" = {
        "description" = "VIDEO"
        "address"     = "${cidrhost(var.networks.video, 1)}/24"
      }
    }
  })
}

resource "vyos_config" "interface-rescue" {
  path = "interfaces ethernet ${var.config.zones.rescue.interface}"
  value = jsonencode({
    "address"     = "${cidrhost(var.networks.rescue, 1)}/24"
    "description" = "RESCUE"
    "hw-id"       = "00:f4:21:68:3e:9e"
  })
}

resource "vyos_config" "interface-wireguard" {
  path = "interfaces wireguard ${var.config.zones.wg_trusted.interface}"
  value = jsonencode({
    "address"     = "${cidrhost(var.networks.wg_trusted, 1)}/24"
    "description" = "WIREGUARD"
    "port"        = tostring(var.config.zones.wg_trusted.port)
    "private-key" = var.secrets.wireguard_private_key
    "peer" = merge([
      for peer, peer_config in var.config.zones.wg_trusted.peers : {
        "${peer}" = {
          "allowed-ips"          = "${cidrhost(var.networks.wg_trusted, peer_config.ipv4_hostid)}/32"
          "public-key"           = "${peer_config.public_key}"
          "persistent-keepalive" = "15"
        }
      }
    ]...)
  })
}
