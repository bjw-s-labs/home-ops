resource "vyos_config" "service-ntp" {
  path = "service ntp"
  value = jsonencode({
    "server" = {
      "nl.pool.ntp.org" = {}
    }
    "allow-client" = {
      "address" = [
        "${var.networks.lan}",
        "${var.networks.servers}",
        "${var.networks.trusted}",
        "${var.networks.iot}",
        "${var.networks.video}",
        "${var.networks.wg_trusted}"
      ]
    }
  })
}
