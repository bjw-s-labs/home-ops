resource "remote_file" "container-coredns-corefile" {
  provider = remote
  path     = "/config/coredns/Corefile"
  content = templatefile(
    pathexpand("${path.module}/../files/coredns/Corefile.tftpl"),
    { domains = var.domains }
  )
  permissions = "0644"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "remote_file" "container-coredns-hosts" {
  provider = remote
  path     = "/config/coredns/hosts"
  content = templatefile(
    pathexpand("${path.module}/../files/coredns/hosts.tftpl"),
    {
      address_book = var.address_book,
      config       = var.config
      networks     = var.networks
    }
  )
  permissions = "0644"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "vyos_config_block_tree" "container-coredns" {
  path = "container name vyos-coredns"

  configs = {
    "cap-add" = "net-bind-service"
    "image"   = "${var.config.containers.coredns.image}"

    "network services address" = "${cidrhost(var.networks.services, 3)}"

    "volume config destination" = "/config"
    "volume config source"      = "/config/coredns"
  }

  depends_on = [
    vyos_config_block_tree.container_network-services,
    remote_file.container-coredns-corefile,
    remote_file.container-coredns-hosts
  ]
}
