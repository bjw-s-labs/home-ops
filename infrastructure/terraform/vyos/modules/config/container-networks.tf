resource "vyos_config" "container_network-services" {
  path = "container network services"
  value = jsonencode({
    "prefix" = "${var.networks.services}"
  })
}
