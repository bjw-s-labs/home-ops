resource "vyos_config" "container-node-exporter" {
  path = "container name node-exporter"
  value = jsonencode({
    "image"  = "${var.config.containers.node-exporter.image}"
    "memory" = "0"
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 7)}"
      }
    }
    "environment" = {
      "procfs" = { "value" = "/host/proc" }
      "rootfs" = { "value" = "/host/rootfs" }
      "sysfs"  = { "value" = "/host/sys" }
    }
    "restart"       = "on-failure"
    "shared-memory" = "0"
    "volume" = {
      "procfs" = {
        "source"      = "/proc"
        "destination" = "/host/proc"
        # "mode"        = "ro"
      }
      "rootfs" = {
        "source"      = "/"
        "destination" = "/host/rootfs"
        # "mode"        = "ro"
      }
      "sysfs" = {
        "source"      = "/sys"
        "destination" = "/host/sys"
        # "mode"        = "ro"
      }
    }
  })
}
