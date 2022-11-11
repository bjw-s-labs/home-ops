resource "vyos_config" "system-hostname" {
  path = "system host-name"
  value = jsonencode(
    var.config.hostname
  )
}

resource "vyos_config" "system-domain_name" {
  path = "system domain-name"
  value = jsonencode(
    sensitive(var.config.domain_name)
  )
}

resource "vyos_config" "system-name_server" {
  path = "system name-server"
  value = jsonencode(
    var.config.upstream_name_server
  )
}

resource "vyos_config" "system-time_zone" {
  path = "system time-zone"
  value = jsonencode(
    var.config.time_zone
  )
}
