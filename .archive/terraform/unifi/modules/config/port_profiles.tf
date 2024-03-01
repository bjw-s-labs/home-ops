resource "unifi_port_profile" "all" {
  name                  = "All"
  native_networkconf_id = data.unifi_network.default.id

  autoneg  = true
  forward  = "all"
  poe_mode = "auto"
}

resource "unifi_port_profile" "iot" {
  name                  = "IoT"
  native_networkconf_id = unifi_network.iot.id

  autoneg  = true
  forward  = "native"
  poe_mode = "auto"
}

resource "unifi_port_profile" "iot_poe_disabled" {
  name                  = "IoT - no PoE"
  native_networkconf_id = unifi_network.iot.id

  autoneg  = true
  forward  = "native"
  poe_mode = "off"
}

resource "unifi_port_profile" "servers" {
  name                  = "Servers"
  native_networkconf_id = unifi_network.servers.id

  autoneg  = true
  forward  = "native"
  poe_mode = "auto"
}

resource "unifi_port_profile" "video" {
  name                  = "Video"
  native_networkconf_id = unifi_network.video.id

  autoneg  = true
  forward  = "native"
  poe_mode = "auto"
}

resource "unifi_port_profile" "disabled" {
  name = "Disabled"

  forward  = "disabled"
  poe_mode = "off"
}

data "unifi_port_profile" "k8s_server" {
  name = "k8s-server"
  site = unifi_site.default.name
}
