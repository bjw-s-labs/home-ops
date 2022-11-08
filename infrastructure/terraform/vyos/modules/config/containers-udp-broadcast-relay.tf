resource "vyos_config_block_tree" "container-udp-broadcast-relay-mdns" {
  path = "container name udp-broadcast-relay-mdns"

  configs = {
    "cap-add" = "net-raw"
    "image"   = "${var.config.containers.udp-broadcast-relay.image}"

    "allow-host-networks" = ""

    "environment CFG_ID value"        = "2"
    "environment CFG_PORT value"      = "5353"
    "environment CFG_DEV value"       = "${var.config.zones.trusted.interface};${var.config.zones.iot.interface}"
    "environment CFG_MULTICAST value" = "224.0.0.251"
    "environment SEPARATOR value"     = ";"
  }
}

resource "vyos_config_block_tree" "container-udp-broadcast-relay-sonos" {
  path = "container name udp-broadcast-relay-sonos"

  configs = {
    "cap-add" = "net-raw"
    "image"   = "${var.config.containers.udp-broadcast-relay.image}"

    "allow-host-networks" = ""

    "environment CFG_ID value"        = "1"
    "environment CFG_PORT value"      = "1900"
    "environment CFG_DEV value"       = "${var.config.zones.trusted.interface};${var.config.zones.iot.interface}"
    "environment CFG_MULTICAST value" = "239.255.255.250"
    "environment SEPARATOR value"     = ";"
  }
}
