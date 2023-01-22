resource "vyos_config" "service-ntp" {
  path = "service ntp"
  value = jsonencode(
    merge(
      {
        "listen-address" = [
          "${cidrhost(var.networks.lan, 1)}",
          "${cidrhost(var.networks.servers, 1)}",
          "${cidrhost(var.networks.trusted, 1)}",
          "${cidrhost(var.networks.iot, 1)}",
          "${cidrhost(var.networks.video, 1)}"
        ],
        "allow-client" = {
          "address" = [
            "0.0.0.0/0",
            "::/0"
          ]
        },
        "server" = {
          "0.nl.pool.ntp.org" = {},
          "1.nl.pool.ntp.org" = {},
          "2.nl.pool.ntp.org" = {},
          "3.nl.pool.ntp.org" = {}
        }
      },
    )
  )
}
