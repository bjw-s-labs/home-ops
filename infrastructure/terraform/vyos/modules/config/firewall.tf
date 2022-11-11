locals {
  host_groups = distinct(
    flatten([
      for host in var.address_book.hosts : [
        for group in host.groups : group
      ] if lookup(host, "groups", false) != false
    ])
  )

  host_groups_with_addresses = merge(flatten([
    for host_group in local.host_groups : [
      {
        "${host_group}" : {
          "addresses" : flatten([
            for host in var.address_book.hosts :
            cidrhost(var.networks[host.network], host.ipv4_hostid)
            if contains(lookup(host, "groups", []), host_group)
          ])
        }
      }
    ]
  ])...)

  zone_combinations = flatten([
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
    for zone in local.zone_combinations : {
      "zoneFrom" : zone.zoneFrom
      "zoneTo" : zone.zoneTo
      "name" : "${zone.zoneFrom}-${zone.zoneTo}"
      "description" : "From ${upper(zone.zoneFrom)} to ${upper(zone.zoneTo)}"
      "defaultAction" : lookup(zone.fw_config, "default", "drop")
      "defaultLog" : lookup(zone.fw_config, "defaultLog", true)
      "rules" : [
        for index, rule in lookup(zone.fw_config, "rules", []) : {
          "description" : "Rule: ${keys(rule)[0]}"
          "log" : lookup(var.firewall_rules[keys(rule)[0]], "log", false)
          "index" : index + 1
          "action" : lookup(var.firewall_rules[keys(rule)[0]], "action", null)
          "protocol" : lookup(var.firewall_rules[keys(rule)[0]], "protocol", null)
          "state" : lookup(var.firewall_rules[keys(rule)[0]], "state", null)
          "source" : lookup(var.firewall_rules[keys(rule)[0]], "source", null)
          "destination" : lookup(var.firewall_rules[keys(rule)[0]], "destination", null)
        }
      ]
    }
  ])
}

data "http" "cloudflare_ips" {
  url = "https://api.cloudflare.com/client/v4/ips"
  request_headers = {
    Accept = "application/json"
  }
}

resource "vyos_config" "firewall_group_address-group" {
  path = "firewall group address-group"
  value = jsonencode(merge(
    merge(
      flatten([
        for host_group, host_group_config in local.host_groups_with_addresses : {
          # This is a bit of a hack because VyOS reports a string if there is only a single value
          # Terraform can't handle different types for the true and false result expressions
          "${host_group}" = merge(
            length(host_group_config.addresses) > 1 ? {
              "address" =  sort(host_group_config.addresses)
            } : {},
            length(host_group_config.addresses) == 1 ? {
              "address" = host_group_config.addresses[0]
            } : {}
          )
        }
      ])...
    )
    ,
    flatten([
      for service, service_config in var.address_book.services : {
        "${service}" = {
          "address" = service_config.ipv4_addr
        }
      }
    ])...
  ))
}

resource "vyos_config" "firewall_group_port-group" {
  path = "firewall group port-group"
  value = jsonencode(
    flatten([
      for port_group in var.config.firewall.port_groups : {
        # This is a bit of a hack because VyOS reports a string if there is only a single value
        # Terraform can't handle different types for the true and false result expressions
        "${port_group.name}" = merge(
          length(port_group.ports) > 1 ? {
            "port" = sort(port_group.ports)
          } : {},
          length(port_group.ports) == 1 ? {
            "port" = tostring(port_group.ports[0])
          } : {}
        )
      }
    ])...
  )
}

resource "vyos_config" "firewall_group_network-group" {
  path = "firewall group network-group"
  value = jsonencode(
    merge(
      {
        # Cloudflare IPv4
        "cloudflare-ipv4" = {
          "network" = jsondecode(data.http.cloudflare_ips.response_body).result.ipv4_cidrs
        }
      },

      # From config
      flatten([
        for network_group in var.config.firewall.network_groups : {
          # This is a bit of a hack because VyOS reports a string if there is only a single value
          # Terraform can't handle different types for the true and false result expressions
          "${network_group.name}" = merge(
            length(network_group.networks) > 1 ? {
              "network" = sort(network_group.networks)
            } : {},
            length(network_group.networks) == 1 ? {
              "network" = network_group.networks[0]
            } : {}
          )
        }
      ])...
    )
  )

  depends_on = [
    data.http.cloudflare_ips
  ]
}

resource "vyos_config" "firewall_name" {
  path = "firewall name"
  value = jsonencode(merge(
    merge([
      for policy in local.firewall_policies : {
        "${policy.zoneFrom}-${policy.zoneTo}" = merge(
          {
            "description"        = "${policy.description}"
            "default-action"     = "${policy.defaultAction}"
          },
          policy.defaultLog != true ? {} : {
            "enable-default-log" = {}
          },
          length(policy.rules) == 0 ? {} :
          {
            "rule" = merge([
              for rule in policy.rules : {
                "${rule.index}" = merge(
                  {
                    "description" = rule.description
                    "action" = rule.action
                  },
                  rule.log == false ? {} :
                    { "log" = "enable" },
                  rule.protocol == null ? {} :
                    { "protocol" = tostring(rule.protocol) },
                  rule.state == null ? {} : {
                    "state" = merge(
                      lookup(rule.state, "established", false) == false ? {} :
                        { "established" = "enable"},
                      lookup(rule.state, "related", false) == false ? {} :
                        { "related" = "enable"},
                      lookup(rule.state, "invalid", false) == false ? {} :
                        { "invalid" = "enable"},
                    )
                  },
                  rule.source == null ? {} : {
                    "source" = merge(
                      lookup(rule.source, "port", null) != null ? { "port" = tostring(rule.source.port)} : {},
                      (lookup(rule.source, "address-group", null) == null && lookup(rule.source, "network-group", null) == null) ? {} :
                      {
                        "group" = merge(
                          lookup(rule.source, "address-group", null) != null ? { "address-group" = rule.source.address-group} : {},
                          lookup(rule.source, "network-group", null) != null ? { "network-group" = rule.source.network-group} : {},
                        )
                      }
                    )
                  },
                  rule.destination == null ? {} : {
                    "destination" = merge(
                      lookup(rule.destination, "port", null) != null ? { "port" = tostring(rule.destination.port)} : {},
                      (lookup(rule.destination, "address-group", null) == null && lookup(rule.destination, "network-group", null) == null) ? {} :
                      {
                        "group" = merge(
                          lookup(rule.destination, "address-group", null) != null ? { "address-group" = rule.destination.address-group} : {},
                          lookup(rule.destination, "network-group", null) != null ? { "network-group" = rule.destination.network-group} : {},
                        )
                      }
                    )
                  }
                )
              }
            ]...)
          }
        )
      }
    ]...),
  ))

  depends_on = [
    vyos_config.firewall_group_address-group,
    vyos_config.firewall_group_port-group
  ]
}

resource "vyos_config" "firewall_zone" {
  path = "firewall zone"
  value = jsonencode(
    merge(
      merge([
        for zone, zone_config in var.config.zones : {
          "${zone}" = merge(
            { "default-action" = "drop" },
            lookup(zone_config, "description", null) == null ? {} :
              { "description" = zone_config.description},
            lookup(zone_config, "local_zone", false) == false ? {} :
              { "local-zone" = {} },
            lookup(zone_config, "interface", null) == null ? {} :
              { "interface" = zone_config.interface},
            {
              "from" = merge([
                for firewall_policy in local.firewall_policies : {
                  "${firewall_policy.zoneFrom}" = {
                    "firewall" = {
                      "name" = firewall_policy.name
                    }
                  }
                } if firewall_policy.zoneTo == zone
              ]...)
            }
          )
        }
      ]...),
    )
  )

  depends_on = [
    vyos_config.firewall_name
  ]
}
