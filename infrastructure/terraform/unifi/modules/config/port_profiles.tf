data "unifi_port_profile" "all" {
  name = "All"
  site = unifi_site.default.name
}

data "unifi_port_profile" "disabled" {
  name = "Disabled"
  site = unifi_site.default.name
}

data "unifi_port_profile" "servers" {
  name = "Servers"
  site = unifi_site.default.name
}

data "unifi_port_profile" "iot" {
  name = "IoT"
  site = unifi_site.default.name
}

data "unifi_port_profile" "video" {
  name = "Video"
  site = unifi_site.default.name
}

resource "unifi_port_profile" "iot_poe_disabled" {
  name = "IoT - PoE disabled"
  site = unifi_site.default.name

  native_networkconf_id = unifi_network.iot.id
  poe_mode              = "off"
}
