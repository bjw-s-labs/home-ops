resource "vyos_config" "container-unifi" {
  path = "container name unifi"
  value = jsonencode({
    "image" = "${var.config.containers.unifi.image}"
    "memory" = "1024"
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 10)}"
      }
    }
    "environment" = {
      "RUNAS_UID0"   = { "value" = "false" }
      "UNIFI_UID"    = { "value" = "999" }
      "UNIFI_GID"    = { "value" = "999" }
      "UNIFI_STDOUT" = { "value" = "true" }
      "TZ"           = { "value" = "Europe/Amsterdam" }
    }
    "volume" = {
      "data" = {
        "source"      = "/config/unifi/data"
        "destination" = "/unifi"
      }
    }
  })

  depends_on = [
    vyos_config.container_network-services
  ]
}
