resource "vyos_config_block_tree" "container_network-services" {
  path = "container network services"

  configs = {
    "prefix" = "${var.networks.services}"
  }
}
