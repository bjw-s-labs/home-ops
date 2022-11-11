resource "vyos_config" "service-https-api_keys" {
  for_each = var.config.api.keys
  path     = "service https api keys id ${each.key} key"
  value = jsonencode(
    sensitive(each.value)
  )
}

resource "vyos_config" "service-https-api-virtual_host-default" {
  path = "service https virtual-host default"
  value = jsonencode({
    "listen-address" = var.config.api.listen_address
    "listen-port"    = tostring(var.config.api.port)
  })
}
