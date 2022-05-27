resource "vyos_config" "system-hostname" {
  key   = "system host-name"
  value = var.config.hostname
}

resource "vyos_config" "system-domain_name" {
  key   = "system domain-name"
  value = sensitive(var.config.domain_name)
}

resource "vyos_config" "system-name_server" {
  key   = "system name-server"
  value = var.config.upstream_name_server
}

resource "vyos_config" "system-time_zone" {
  key   = "system time-zone"
  value = var.config.time_zone
}
