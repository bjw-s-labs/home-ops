resource "vyos_config_block_tree" "protocols-bgp" {
  path = "protocols bgp"
  configs = merge(
    {
      # main setup
      "system-as"             = var.config.bgp.local_as
      "parameters router-id" = var.config.bgp.router_id
    },

    merge(flatten([
      for neighbour_group in var.config.bgp.neighbor_groups : [
        for hostname, host in var.address_book.hosts : [
          {
            "neighbor ${cidrhost(var.networks[host.network], host.ipv4_hostid)} remote-as" : neighbour_group.remote_as
            "neighbor ${cidrhost(var.networks[host.network], host.ipv4_hostid)} description" : hostname
            "neighbor ${cidrhost(var.networks[host.network], host.ipv4_hostid)} address-family ipv4-unicast" : ""
          }
        ] if contains(lookup(host, "groups", []), neighbour_group.group)
      ]
    ])...)
  )
}
