resource "vyos_config_block_tree" "interfaces" {
  for_each = var.config.interfaces
  path     = "interfaces ethernet ${each.value.interface}"

  configs = merge(
    {
      # main setup
      "address"     = each.value.router_cidr
      "description" = try(each.value.description, upper(each.key))
    },
    merge([
      for name, vlan in try(each.value.vlans, {}) : {
        "vif ${vlan.vlan_id} address"     = vlan.router_cidr
        "vif ${vlan.vlan_id} description" = try(vlan.description, upper(name))
      }
    ]...)
  )
}
