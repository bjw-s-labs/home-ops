resource "vyos_config_block_tree" "nat-source" {
  path = "nat source"

  configs = merge([
    {
      "rule 100 description"         = "LAN -> WAN"
      "rule 100 outbound-interface"  = var.config.zones.wan.interface
      "rule 100 destination address" = "0.0.0.0/0"
      "rule 100 translation address" : "masquerade"
    }
    ]...
  )
  depends_on = [
    vyos_config_block_tree.interface-wan,
    vyos_config_block_tree.interface-lan
  ]
}

resource "vyos_config_block_tree" "nat-destination" {
  path = "nat destination"

  configs = merge(
    merge([
      for index, rule in var.config.nat.destination :
      {
        "rule ${100 + index} description" : "${rule.description}"
        "rule ${100 + index} destination address" : contains(keys(rule), "destinationAddress") ? rule.destinationAddress : null
        "rule ${100 + index} destination port" : rule.port
        "rule ${100 + index} inbound-interface" : var.config.zones[rule.interface].interface
        "rule ${100 + index} protocol" : rule.protocol
        "rule ${100 + index} translation address" : rule.address
        "rule ${100 + index} translation port" : contains(keys(rule), "translationPort") ? rule.translationPort : rule.port
      }
    ]...)
  )
  depends_on = [
    vyos_config_block_tree.interface-wan,
    vyos_config_block_tree.interface-lan
  ]
}
