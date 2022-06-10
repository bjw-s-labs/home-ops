resource "vyos_config_block_tree" "firewall_name" {
  path = "firewall name"

  configs = merge(
    merge([
      for policy in local.firewall_policies : {
        "name ${policy.zoneFrom}-${policy.zoneTo} description"        = "${policy.description}"
        "name ${policy.zoneFrom}-${policy.zoneTo} default-action"     = "${policy.defaultAction}"
        "name ${policy.zoneFrom}-${policy.zoneTo} enable-default-log" = (policy.defaultLog == true ? "" : null)
      }
    ]...),

    merge([
      for rule in local.firewall_rules_per_policy : {
        "name ${rule.policy} rule ${rule.index} description" = rule.description
        "name ${rule.policy} rule ${rule.index} action"      = rule.action
        "name ${rule.policy} rule ${rule.index} protocol"    = rule.protocol

        "name ${rule.policy} rule ${rule.index} state established" = lookup(rule.state, "established", false) == true ? "enable" : null
        "name ${rule.policy} rule ${rule.index} state related"     = lookup(rule.state, "related", false) == true ? "enable" : null
        "name ${rule.policy} rule ${rule.index} state invalid"     = lookup(rule.state, "invalid", false) == true ? "enable" : null

        "name ${rule.policy} rule ${rule.index} source port"                = lookup(rule.source, "port", null)
        "name ${rule.policy} rule ${rule.index} source group address-group" = lookup(rule.source, "address-group", null)
        "name ${rule.policy} rule ${rule.index} source group network-group" = lookup(rule.source, "network-group", null)

        "name ${rule.policy} rule ${rule.index} destination port"                = lookup(rule.destination, "port", null)
        "name ${rule.policy} rule ${rule.index} destination group address-group" = lookup(rule.destination, "address-group", null)
        "name ${rule.policy} rule ${rule.index} destination group network-group" = lookup(rule.destination, "network-group", null)
      }
    ]...),
  )
}
