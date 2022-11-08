resource "vyos_config_block_tree" "service-dhcp-server" {
  path = "service dhcp-server"

  configs = merge(
    {
      # main setup
      "hostfile-update" = "" # Create DNS record per client lease, by adding clients to /etc/hosts file. Entry will have format: <shared-network-name>_<hostname>.<domain-name>
      "host-decl-name"  = "" # Will drop <shared-network-name>_ from client DNS record, using only the host declaration name and domain: <hostname>.<domain-name>
    },

    merge([
      for zone, zone_config in var.config.zones : {
        "shared-network-name ${upper(zone)} authoritative"                               = ""
        "shared-network-name ${upper(zone)} ping-check"                                  = ""
        "shared-network-name ${upper(zone)} subnet ${var.networks[zone]} domain-name"    = lookup(zone_config.dhcp, "domain_name", null)
        "shared-network-name ${upper(zone)} subnet ${var.networks[zone]} default-router" = lookup(zone_config.dhcp, "default_router", cidrhost(var.networks[zone], 1))
        "shared-network-name ${upper(zone)} subnet ${var.networks[zone]} lease"          = "86400"
        "shared-network-name ${upper(zone)} subnet ${var.networks[zone]} name-server"    = lookup(zone_config.dhcp, "name_server", cidrhost(var.networks[zone], 1))
        "shared-network-name ${upper(zone)} subnet ${var.networks[zone]} range 0 start"  = lookup(zone_config.dhcp, "start", cidrhost(var.networks[zone], 200))
        "shared-network-name ${upper(zone)} subnet ${var.networks[zone]} range 0 stop"   = lookup(zone_config.dhcp, "start", cidrhost(var.networks[zone], 254))
      } if lookup(zone_config, "dhcp", false) != false
    ]...),

    merge([
      for hostname, host in var.address_book.hosts : {
        "shared-network-name ${upper(host.network)} subnet ${var.networks[host.network]} static-mapping ${hostname} mac-address" = host.mac_addr
        "shared-network-name ${upper(host.network)} subnet ${var.networks[host.network]} static-mapping ${hostname} ip-address"  = cidrhost(var.networks[host.network], host.ipv4_hostid)
      } if lookup(host, "mac_addr", false) != false
    ]...),
  )
}
