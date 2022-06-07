resource "vyos_config_block_tree" "service-dhcp-server" {
  path = "service dhcp"

  configs = merge(
    {
      # main setup
      "hostfile-update" = "" # Create DNS record per client lease, by adding clients to /etc/hosts file. Entry will have format: <shared-network-name>_<hostname>.<domain-name>
      "host-decl-name"  = "" # Will drop <shared-network-name>_ from client DNS record, using only the host declaration name and domain: <hostname>.<domain-name>
    },
    merge([
      # Loop over zones
      for index, zone in ["lan", "rescue", "servers", "trusted", "iot", "video"] :
      {
        "shared-network-name ${zone} domain-name"                                 = var.config[zone].dhcp.domain_name != "" ? var.config[zone].dhcp.domain_name : null,
        "shared-network-name ${zone} ping-check"                                  = "",
        "shared-network-name ${zone} subnet ${var.networks[zone]} default-router" = var.config[zone].dhcp.name_server != "" ? var.config[zone].dhcp.default_router : cidrhost(var.networks[zone], 1)
        "shared-network-name ${zone} subnet ${var.networks[zone]} lease"          = "86400",
        "shared-network-name ${zone} subnet ${var.networks[zone]} name-server"    = var.config[zone].dhcp.name_server != "" ? var.config[zone].dhcp.name_server : cidrhost(var.networks[zone], 1)
        "shared-network-name ${zone} subnet ${var.networks[zone]} range 0 start"  = var.config[zone].dhcp.start != "" ? var.config[zone].dhcp.start : 100
        "shared-network-name ${zone} subnet ${var.networks[zone]} range 0 stop"   = var.config[zone].dhcp.stop != "" ? var.config[zone].dhcp.stop : 254
      }
    ]...),
    # merge([
    #   # static allocation
    #   for host in local.host_by_name_with_mac : {
    #     "shared-network-name lan subnet ${var.config.lan.cidr} static-mapping ${host.name}${trimsuffix(host.name, ".") != host.name ? "" : ".${var.config.lan.dhcp.domain_name}" } mac-address" = host.mac
    #     "shared-network-name lan subnet ${var.config.lan.cidr} static-mapping ${host.name}${trimsuffix(host.name, ".") != host.name ? "" : ".${var.config.lan.dhcp.domain_name}" } ip-address" = host.ip
    #   } if lookup(host, "is_dhcp", true)
    # ]...),
  )
}
