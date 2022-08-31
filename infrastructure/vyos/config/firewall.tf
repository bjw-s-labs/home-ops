data "http" "cloudflare_ips" {
  url = "https://api.cloudflare.com/client/v4/ips"

  request_headers = {
    Accept = "application/json"
  }
}

resource "vyos_config_block_tree" "firewall_group_address-group" {
  path = "firewall group address-group"

  configs = merge(
    merge(flatten([
      for host_group, host_group_config in local.host_groups_with_addresses : {
        "${host_group} address" = length(host_group_config.addresses) > 1 ? jsonencode(host_group_config.addresses) : host_group_config.addresses[0]
      }
    ])...),

    merge(flatten([
      for service, service_config in var.address_book.services : {
        "${service} address" = service_config.ipv4_addr
      }
    ])...),
  )
}

resource "vyos_config_block_tree" "firewall_group_port-group" {
  path = "firewall group port-group"

  configs = merge(
    merge(flatten([
      for port_group in var.config.firewall.port_groups : {
        "${port_group.name} port" = length(port_group.ports) > 1 ? jsonencode(port_group.ports) : port_group.ports[0]
      }
    ])...),
  )
}

resource "vyos_config_block_tree" "firewall_group_network-group" {
  path = "firewall group network-group"

  configs = merge(
    {
      # Cloudflare IPv4
      "cloudflare-ipv4 network" = jsonencode(jsondecode(data.http.cloudflare_ips.response_body).result.ipv4_cidrs)
    },

    # From config
    merge(flatten([
      for network_group in var.config.firewall.network_groups : {
        "${network_group.name} network" = length(network_group.networks) > 1 ? jsonencode(network_group.networks) : network_group.networks[0]
      }
    ])...),
  )
  depends_on = [
    data.http.cloudflare_ips
  ]
}

resource "vyos_config_block_tree" "firewall_name" {
  path = "firewall name"

  configs = merge(
    merge([
      for policy in local.firewall_policies : {
        "${policy.zoneFrom}-${policy.zoneTo} description"        = "${policy.description}"
        "${policy.zoneFrom}-${policy.zoneTo} default-action"     = "${policy.defaultAction}"
        "${policy.zoneFrom}-${policy.zoneTo} enable-default-log" = (policy.defaultLog == true ? "" : null)
      }
    ]...),

    merge([
      for rule in local.firewall_rules_per_policy : {
        "${rule.policy} rule ${rule.index} description" = rule.description
        "${rule.policy} rule ${rule.index} log"         = lookup(rule, "log", false) == true ? "enable" : null
        "${rule.policy} rule ${rule.index} action"      = rule.action
        "${rule.policy} rule ${rule.index} protocol"    = rule.protocol

        "${rule.policy} rule ${rule.index} state established" = lookup(rule.state, "established", false) == true ? "enable" : null
        "${rule.policy} rule ${rule.index} state related"     = lookup(rule.state, "related", false) == true ? "enable" : null
        "${rule.policy} rule ${rule.index} state invalid"     = lookup(rule.state, "invalid", false) == true ? "enable" : null

        "${rule.policy} rule ${rule.index} source port"                = lookup(rule.source, "port", null)
        "${rule.policy} rule ${rule.index} source group address-group" = lookup(rule.source, "address-group", null)
        "${rule.policy} rule ${rule.index} source group network-group" = lookup(rule.source, "network-group", null)

        "${rule.policy} rule ${rule.index} destination port"                = lookup(rule.destination, "port", null)
        "${rule.policy} rule ${rule.index} destination group address-group" = lookup(rule.destination, "address-group", null)
        "${rule.policy} rule ${rule.index} destination group network-group" = lookup(rule.destination, "network-group", null)
      }
    ]...),
  )
  depends_on = [
    vyos_config_block_tree.firewall_group_address-group,
    vyos_config_block_tree.firewall_group_port-group
  ]
}
