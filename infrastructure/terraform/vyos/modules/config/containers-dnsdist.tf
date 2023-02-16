resource "remote_file" "container-dnsdist-config" {
  provider = remote
  path     = "/config/dnsdist/dnsdist.conf"
  content = templatefile(
    pathexpand("${path.root}/files/dnsdist/dnsdist.conf.tftpl"),
    {
      networks     = var.networks
      address_book = var.address_book
    }
  )
  permissions = "0775"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "vyos_config" "container-dnsdist" {
  path = "container name dnsdist"
  value = jsonencode({
    "cap-add" = "net-bind-service"
    "image"   = "${var.config.containers.dnsdist.image}"
    "memory"  = "512"
    "environment" = {
      "TZ" = { "value" = "Europe/Amsterdam" }
    }
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 6)}"
      }
    }
    "restart" = "on-failure"
    "volume" = {
      "config" = {
        "destination" = "/etc/dnsdist/dnsdist.conf"
        "source"      = "/config/dnsdist/dnsdist.conf"
      }
    }
  })

  depends_on = [
    vyos_config.container_network-services,
    remote_file.container-dnsdist-config
  ]
}
