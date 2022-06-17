resource "remote_file" "container-vector-agent-config" {
  provider = remote
  path     = "/config/vector-agent/vector.yaml"
  content = templatefile(
    pathexpand("${path.module}/../files/vector-agent/vector.yaml.tftpl"),
    { address_book = var.address_book }
  )
  permissions = "0644"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "vyos_config_block_tree" "container-vector-agent" {
  path = "container name vector-agent"

  configs = {
    "image" = "${var.config.containers.vector.image}"

    "network services address" = "${cidrhost(var.networks.services, 4)}"

    "environment VECTOR_CONFIG value"       = "/etc/vector/vector.yaml"
    "environment VECTOR_WATCH_CONFIG value" = "true"

    "volume config destination" = "/etc/vector/vector.yaml"
    "volume config source"      = "/config/vector-agent/vector.yaml"
    "volume data destination"   = "/var/lib/vector"
    "volume data source"        = "/config/vector-agent/data"
    "volume logs destination"   = "/var/log"
    "volume logs source"        = "/var/log"
  }

  depends_on = [
    vyos_config_block_tree.container_network-services,
    remote_file.container-vector-agent-config
  ]
}
