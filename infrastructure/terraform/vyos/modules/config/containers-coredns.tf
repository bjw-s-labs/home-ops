resource "remote_file" "container-coredns-corefile" {
  provider = remote
  path     = "/config/coredns/Corefile"
  content = templatefile(
    pathexpand("${path.root}/files/coredns/Corefile.tftpl"),
    { domains = var.domains }
  )
  permissions = "0775"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "remote_file" "container-coredns-hosts" {
  provider = remote
  path     = "/config/coredns/hosts"
  content = templatefile(
    pathexpand("${path.root}/files/coredns/hosts.tftpl"),
    {
      address_book = var.address_book,
      config       = var.config
      networks     = var.networks
    }
  )
  permissions = "0775"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "vyos_config" "container-coredns" {
  path = "container name vyos-coredns"
  value = jsonencode({
    "cap-add" = "net-bind-service"
    "image"   = "${var.config.containers.coredns.image}"
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 3)}"
      }
    }
    "volume" = {
      "config" = {
        "source"      = "/config/coredns"
        "destination" = "/config"
      }
    }
  })

  depends_on = [
    vyos_config.container_network-services,
    remote_file.container-coredns-corefile,
    remote_file.container-coredns-hosts
  ]
}
