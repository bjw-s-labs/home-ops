resource "vyos_config" "nat-source" {
  path = "nat source"
  value = jsonencode({
    "rule" = {
      "100" = {
        "description"        = "LAN -> WAN"
        "outbound-interface" = var.config.zones.wan.interface
        "destination" = {
          "address" = "0.0.0.0/0"
        }
        "translation" = { "address" : "masquerade" }
      }
    }
  })

  depends_on = [
    vyos_config.interface-wan,
    vyos_config.interface-lan
  ]
}

resource "vyos_config" "nat-destination" {
  path = "nat destination"
  value = jsonencode({
    "rule" = merge([
      for index, rule in var.config.nat.destination :
      {
        "${100 + index}" = {
          "description" : "${rule.description}"
          "destination" = merge(
            contains(keys(rule), "destinationAddress") ? {
              "address" = rule.destinationAddress
            } : {},
            {
              "port" = tostring(rule.port)
            }
          )
          "inbound-interface" = var.config.zones[rule.interface].interface
          "protocol"          = rule.protocol
          "translation" = {
            "address" = rule.address
            "port"    = tostring(contains(keys(rule), "translationPort") ? rule.translationPort : rule.port)
          }
        }
      }
    ]...)
  })

  depends_on = [
    vyos_config.interface-wan,
    vyos_config.interface-lan
  ]
}
