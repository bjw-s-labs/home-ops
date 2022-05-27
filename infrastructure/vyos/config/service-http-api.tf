resource "vyos_config" "service-https-api_keys" {
  for_each = var.config.api.keys
  key      = "service https api keys id ${each.key} key"
  value    = sensitive(each.value)
}

resource "vyos_config_block" "service-https-api-virtual_host-default" {
  path = "service https virtual-host default"

  configs = {
    "listen-address" = var.config.api.listen_address
    "listen-port"    = var.config.api.port
  }
}
