resource "vyos_config" "container-chrony" {
  path = "container name chrony"
  value = jsonencode({
    "image"               = "${var.config.containers.chrony.image}"
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 5)}"
      }
    }
    "restart" = "on-failure"
  })
}
