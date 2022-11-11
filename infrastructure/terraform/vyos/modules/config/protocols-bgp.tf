locals {
  bgp_neighbors = flatten([
    for neighbor_group in var.config.bgp.neighbor_groups : [
      for hostname, host in var.address_book.hosts : [
        merge(
          host,
          {
            "hostname" = "${hostname}"
            "remote_as" = neighbor_group.remote_as
          }
        )
      ] if contains(lookup(host, "groups", []), neighbor_group.group)
    ]
  ]...)
}

resource "vyos_config" "protocols-bgp" {
  path = "protocols bgp"
  value = jsonencode(merge(
    {
      # main setup
      "system-as" = tostring(var.config.bgp.local_as)
      "parameters" = {
        "router-id" = var.config.bgp.router_id
      }
    },
    # Optionally add neighbors for any address book entries
    length(local.bgp_neighbors) == 0 ? {} : {
      "neighbor" = merge([
        for host in local.bgp_neighbors :
        {
          "${cidrhost(var.networks[host.network], host.ipv4_hostid)}" = {
            "remote-as"   = tostring(host.remote_as)
            "description" = host.hostname
            "address-family" = {
              "ipv4-unicast" = {}
            }
          }
        }
      ]...)
    }
  ))
}
