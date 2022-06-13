resource "vyos_config_block_tree" "zone-policies" {
  path = "zone-policy zone"

  configs = merge(
    merge([
      for zone, zone_config in var.config.zones : {
        "${zone} default-action" = "drop"
        "${zone} description"    = lookup(zone_config, "description", null)
        "${zone} local-zone"     = (lookup(zone_config, "local_zone", false)) == true ? "" : null
        "${zone} interface"      = lookup(zone_config, "interface", null)
      }
    ]...),

    merge(flatten([
      for zone in keys(var.config.zones) : [
        for firewall_policy in local.firewall_policies : {
          "${zone} from ${firewall_policy.zoneFrom} firewall name" = firewall_policy.name
        } if firewall_policy.zoneTo == zone
      ]
    ])...),
  )

  depends_on = [
    vyos_config_block_tree.firewall_name
  ]
}
