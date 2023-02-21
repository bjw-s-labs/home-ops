resource "vyos_config" "protocols-bgp" {
  path = "protocols bgp"
  value = jsonencode(
    {
      # main setup
      system-as = "64512"
      parameters = {
        router-id = "10.1.0.1"
      }

      # Neighbors
      neighbor = {
        # Kubernetes nodes
        cidrhost(var.networks[var.address_book.hosts.delta.network], var.address_book.hosts.delta.ipv4_hostid) = {
          address-family = {
            ipv4-unicast = {}
          }
          description = "delta"
          remote-as   = "64512"
        }

        cidrhost(var.networks[var.address_book.hosts.enigma.network], var.address_book.hosts.enigma.ipv4_hostid) = {
          address-family = {
            ipv4-unicast = {}
          }
          description = "enigma"
          remote-as   = "64512"
        }

        cidrhost(var.networks[var.address_book.hosts.felix.network], var.address_book.hosts.felix.ipv4_hostid) = {
          address-family = {
            ipv4-unicast = {}
          }
          description = "felix"
          remote-as   = "64512"
        }
      }
    }
  )
}
