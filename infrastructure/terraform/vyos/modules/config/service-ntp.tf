resource "vyos_config" "service-ntp" {
  path = "service ntp"
  value = jsonencode({
    "server" = {
      "${var.address_book.services.vyos_chronyd.ipv4_addr}" = {}
    }
  })
}
