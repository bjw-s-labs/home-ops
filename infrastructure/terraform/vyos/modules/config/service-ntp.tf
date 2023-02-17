resource "vyos_config" "service-ntp" {
  path = "service ntp"
  value = jsonencode({
    "server" = {
      "0.nl.pool.ntp.org" = {}
      "1.nl.pool.ntp.org" = {}
      "2.nl.pool.ntp.org" = {}
      "3.nl.pool.ntp.org" = {}
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
