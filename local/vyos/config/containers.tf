resource "vyos_config_block_tree" "container_network-services" {
  path = "container network services"

  configs = {
    "prefix" = "${var.networks.services}"
  }
}

# resource "remote_file" "container-coredns-corefile" {
#   provider    = remote
#   path        = "/config/coredns/Corefile"
#   content     = ""
#   permissions = "0644"
# }

resource "vyos_config_block_tree" "container-coredns" {
  path = "container name vyos-coredns"

  configs = {
    "cap-add" = "net-bind-service"
    "image"   = "${var.config.containers.coredns.image}"

    "network services address" = "${cidrhost(var.networks.services, 3)}"

    "volume config destination" = "/config"
    "volume config source"      = "/config/coredns"
  }

  depends_on = [
    vyos_config_block_tree.container_network-services,
    # remote_file.container-coredns-corefile
  ]
}
