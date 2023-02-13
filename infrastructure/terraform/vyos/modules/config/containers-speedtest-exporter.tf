resource "vyos_config" "container-speedtest-exporter" {
  path = "container name speedtest-exporter"
  value = jsonencode({
    "image" = "${var.config.containers.speedtest-exporter.image}"
    "memory" = "0"
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 8)}"
      }
    }
    "restart" = "on-failure"
    "shared-memory" = "0"
  })
}
