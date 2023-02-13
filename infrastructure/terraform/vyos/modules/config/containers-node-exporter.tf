resource "vyos_config" "container-node-exporter" {
  path = "container name node-exporter"
  value = jsonencode({
    "image" = "${var.config.containers.node-exporter.image}"
    "memory" = "0"
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 7)}"
      }
    }
    "restart" = "on-failure"
    "shared-memory" = "0"
    "volume" = {
      "hostroot" = {
        "source"      = "/"
        "destination" = "/host"
      }
    }
  })
}
