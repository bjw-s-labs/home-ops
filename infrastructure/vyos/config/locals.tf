locals {
  _zone_combinations = flatten([
    for zone, zone_config in var.config.zones : [
      for zone_combination in setproduct([zone], setsubtract(keys(var.config.zones), [zone])) : {
        "zoneTo"   = zone
        "zoneFrom" = zone_combination[1]
        "fw_config" = jsondecode(lookup(zone_config, "firewall", null) == null ? jsonencode({}) : (
          lookup(zone_config.firewall, "fromZones", null) == null ? (
            jsonencode(zone_config.firewall.default)
            ) : (
            length([for x in zone_config.firewall.fromZones : x if contains(x.zones, zone_combination[1])]) == 0 ? (
              jsonencode(zone_config.firewall.default)
              ) : (
              jsonencode([for x in zone_config.firewall.fromZones : x if contains(x.zones, zone_combination[1])][0])
            )
          )
        ))
      }
    ]
  ])

  firewall_policies = flatten([
    for zone in local._zone_combinations : {
      "zoneFrom" : zone.zoneFrom
      "zoneTo" : zone.zoneTo
      "name" : "${zone.zoneFrom}-${zone.zoneTo}"
      "description" : "From ${upper(zone.zoneFrom)} to ${upper(zone.zoneTo)}"
      "defaultAction" : lookup(zone.fw_config, "default", "drop")
      "defaultLog" : lookup(zone.fw_config, "defaultLog", true)
    }
  ])

  firewall_rules_per_policy = flatten([
    for zone in local._zone_combinations : [
      for index, rule in lookup(zone.fw_config, "rules", []) : {
        "policy" : "${zone.zoneFrom}-${zone.zoneTo}"
        "description" : "Rule: ${keys(rule)[0]}"
        "log" : lookup(var.firewall_rules[keys(rule)[0]], "log", null)
        "index" : index + 1
        "action" : lookup(var.firewall_rules[keys(rule)[0]], "action", null)
        "protocol" : lookup(var.firewall_rules[keys(rule)[0]], "protocol", null)
        "state" : lookup(var.firewall_rules[keys(rule)[0]], "state", {})
        "source" : lookup(var.firewall_rules[keys(rule)[0]], "source", {})
        "destination" : lookup(var.firewall_rules[keys(rule)[0]], "destination", {})
      }
    ]
  ])
}
