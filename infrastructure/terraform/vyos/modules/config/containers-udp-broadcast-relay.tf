resource "vyos_config" "container-udp-broadcast-relay-sonos" {
  path = "container name udp-broadcast-relay-sonos"
  value = jsonencode({
    "cap-add"             = "net-raw"
    "image"               = "${var.config.containers.udp-broadcast-relay.image}"
    "allow-host-networks" = {}
    "environment" = {
      "CFG_ID"        = { "value" = "1" }
      "CFG_PORT"      = { "value" = "1900" }
      "CFG_DEV"       = { "value" = "${var.config.zones.trusted.interface};${var.config.zones.iot.interface}" }
      "CFG_MULTICAST" = { "value" = "239.255.255.250" }
      "SEPARATOR"     = { "value" = ";" }
    }
    "restart" = "on-failure"
  })
}

resource "vyos_config" "container-udp-broadcast-relay-mdns" {
  path = "container name udp-broadcast-relay-mdns"
  value = jsonencode({
    "cap-add"             = "net-raw"
    "image"               = "${var.config.containers.udp-broadcast-relay.image}"
    "allow-host-networks" = {}
    "environment" = {
      "CFG_ID"        = { "value" = "2" }
      "CFG_PORT"      = { "value" = "5353" }
      "CFG_DEV"       = { "value" = "${var.config.zones.trusted.interface};${var.config.zones.iot.interface}" }
      "CFG_MULTICAST" = { "value" = "224.0.0.251" }
      "SEPARATOR"     = { "value" = ";" }
    }
    "restart" = "on-failure"
  })
}
