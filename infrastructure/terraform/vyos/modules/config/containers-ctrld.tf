resource "remote_file" "container-ctrld-config" {
  provider = remote
  path     = "/config/ctrld/ctrld.toml"
  content = templatefile(
    pathexpand("${path.root}/files/ctrld/ctrld.toml.tftpl"),
    {
      networks     = var.networks
      address_book = var.address_book
    }
  )
  permissions = "0775"
  owner       = "0"   # root
  group       = "104" # vyattacfg
}

resource "vyos_config" "container-ctrld" {
  path = "container name ctrld"
  value = jsonencode({
    "cap-add" = "net-bind-service"
    "image"   = "${var.config.containers.ctrld.image}"
    "memory"  = "512"
    "environment" = {
      "TZ" = { "value" = "Europe/Amsterdam" }
    }
    "network" = {
      "services" = {
        "address" = "${cidrhost(var.networks.services, 9)}"
      }
    }
    "restart" = "on-failure"
    "volume" = {
      "config" = {
        "source"      = "/config/ctrld/ctrld.toml"
        "destination" = "/config/ctrld.toml"
      }
      "logs" = {
        "source"      = "/dev/log"
        "destination" = "/dev/log"
      }
    }
  })

  depends_on = [
    vyos_config.container_network-services,
    remote_file.container-ctrld-config
  ]
}
