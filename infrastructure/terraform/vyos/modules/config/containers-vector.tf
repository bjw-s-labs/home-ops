resource "remote_file" "container-vector-agent-config" {
  provider = remote
  path     = "/config/vector-agent/vector.yaml"
  content = templatefile(
    pathexpand("${path.root}/files/vector-agent/vector.yaml.tftpl"),
    { address_book = var.address_book }
  )
  permissions = "0775"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "vyos_config" "container-vector-agent" {
  path = "container name vector-agent"
  value = jsonencode({
    "image" = "${var.config.containers.vector.image}"
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 4)}"
      }
    }
    "environment" = {
      "VECTOR_CONFIG"       = { "value" = "/etc/vector/vector.yaml" }
      "VECTOR_WATCH_CONFIG" = { "value" = "true" }
    }
    "volume" = {
      "config" = {
        "source"      = "/config/vector-agent/vector.yaml"
        "destination" = "/etc/vector/vector.yaml"
      }
      "data" = {
        "source"      = "/config/vector-agent/data"
        "destination" = "/var/lib/vector"
      }
      "logs" = {
        "source"      = "/var/log"
        "destination" = "/var/log"
      }
    }
  })

  depends_on = [
    vyos_config.container_network-services,
    remote_file.container-vector-agent-config
  ]
}
