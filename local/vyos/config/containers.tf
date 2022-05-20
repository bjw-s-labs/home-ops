# resource "remote_file" "container-coredns-corefile" {
#   provider    = remote
#   path        = "/config/coredns/Corefile"
#   content     = ""
#   permissions = "0644"
# }

resource "vyos_config_block_tree" "container_network-services" {
  path = "container network services"

  configs = {
    "prefix" = "10.5.0.0/24"
  }
}

resource "vyos_config_block_tree" "container-coredns" {
  path = "container name vyos-coredns"

  configs = {
    "cap-add" = "net-bind-service"
    "image"   = "ghcr.io/k8s-at-home/coredns:v1.9.2"

    "network services address" = "10.5.0.3"

    "volume config destination" = "/config"
    "volume config source"      = "/config/coredns"
  }

  depends_on = [
    vyos_config_block_tree.container_network-services
  ]
}
