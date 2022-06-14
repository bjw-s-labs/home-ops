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
      for host in var.address_book.hosts : [
        for group in host.groups : {
          "${group} address ${cidrhost(var.networks[host.network], host.ipv4_hostid)}" = ""
        }
      ] if lookup(host, "groups", false) != false
    ])...),

    merge(flatten([
      for service, service_config in var.address_book.services : {
        "${service} address ${service_config.ipv4_addr}" = ""
      }
    ])...),
  )
}

resource "vyos_config_block_tree" "firewall_group_port-group" {
  path = "firewall group port-group"

  configs = merge(
    merge(flatten([
      for port_group in var.config.firewall.port_groups : [
        for port in port_group.ports : {
          "${port_group.name} port ${port}" = ""
        }
      ]
    ])...),
  )
}

resource "vyos_config_block_tree" "firewall_group_network-group" {
  path = "firewall group network-group"

  configs = merge(
    # Cloudflare IPv4
    merge([
      for ipv4_cidr in jsondecode(data.http.cloudflare_ips.body).result.ipv4_cidrs : {
        "cloudflare-ipv4 network ${ipv4_cidr}" = ""
      }
    ]...),

    # From config
    merge(flatten([
      for network_group in var.config.firewall.network_groups : [
        for network in network_group.networks : {
          "${network_group.name} network ${network}" = ""
        }
      ]
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
