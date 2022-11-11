locals {
  static_mappings_per_zone_unfiltered = merge([
    for zone, zone_config in var.config.zones : {
      "${zone}" : merge([
        for hostname, host in var.address_book.hosts : {
          "${hostname}" : host
        } if(lookup(host, "mac_addr", false) != false && lookup(host, "network", false) == zone)
      ]...)
    }
  ]...)

  static_mappings_per_zone = {
    for zone, zone_config in local.static_mappings_per_zone_unfiltered :
    zone => zone_config if zone_config != {}
  }
}

resource "vyos_config" "service-dhcp-server" {
  path = "service dhcp-server"
  value = jsonencode(
    {
      # main setup
      "hostfile-update" = {} # Create DNS record per client lease, by adding clients to /etc/hosts file. Entry will have format: <shared-network-name>_<hostname>.<domain-name>
      "host-decl-name"  = {} # Will drop <shared-network-name>_ from client DNS record, using only the host declaration name and domain: <hostname>.<domain-name>
      "shared-network-name" = merge([
        for zone, zone_config in var.config.zones : {
          "${upper(zone)}" = {
            "authoritative" = {}
            "ping-check"    = {}
            "subnet" = {
              "${var.networks[zone]}" = merge(
                # Optionally set domain-name
                lookup(zone_config.dhcp, "domain_name", null) == null ? {} : {
                  "domain-name" = zone_config.dhcp.domain_name
                },
                {
                  "default-router" = lookup(zone_config.dhcp, "default_router", cidrhost(var.networks[zone], 1))
                  "lease"          = "86400"
                  "name-server"    = lookup(zone_config.dhcp, "name_server", cidrhost(var.networks[zone], 1))
                  "range" = {
                    "0" = {
                      "start" = lookup(zone_config.dhcp, "start", cidrhost(var.networks[zone], 200))
                      "stop"  = lookup(zone_config.dhcp, "start", cidrhost(var.networks[zone], 254))
                    }
                  }
                },
                # Optionally add static-mappings for any address book entries in this zone
                lookup(local.static_mappings_per_zone, zone, null) == null ? {} : {
                  "static-mapping" = merge([
                    for hostname, host in local.static_mappings_per_zone[zone] : {
                      "${hostname}" = {
                        "mac-address" = host.mac_addr
                        "ip-address"  = cidrhost(var.networks[host.network], host.ipv4_hostid)
                      }
                    }
                  ]...)
                }
              )
            }
          }
        } if lookup(zone_config, "dhcp", false) != false
      ]...)
    },
  )
}
