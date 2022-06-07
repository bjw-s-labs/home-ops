locals {
  host_by_name          = { for host in var.network_clients.hosts : host.name => host}
  //host_by_name          = { for host in slice(var.network_clients.hosts,1,80) : host.name => host}
  host_by_name_with_mac = { for host in var.network_clients.hosts : host.name => host if host.mac != null }
  //host_by_name_with_mac = { for host in slice(var.network_clients.hosts,1,80) : host.name => host if host.mac != null }
}
