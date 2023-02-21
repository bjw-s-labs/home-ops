resource "vyos_config" "service-dns-dynamic-personal" {
  path = "service dns dynamic interface eth0 service personal"
  value = jsonencode(
    {
      "host-name" = "ipv4.bjws.nl"
      "server"    = "api.cloudflare.com/client/v4"
      "protocol"  = "cloudflare"
      "zone"      = "bjws.nl"
      "login"     = "${var.secrets.cloudflare_dyndns_login}"
      "password"  = "${var.secrets.cloudflare_dyndns_token}"
    }
  )
}

resource "vyos_config" "service-dns-dynamic-family" {
  path = "service dns dynamic interface eth0 service family"
  value = jsonencode(
    {
      "host-name" = "ipv4.schorgers.nl"
      "server"    = "api.cloudflare.com/client/v4"
      "protocol"  = "cloudflare"
      "zone"      = "schorgers.nl"
      "login"     = "${var.secrets.cloudflare_dyndns_login}"
      "password"  = "${var.secrets.cloudflare_dyndns_token}"
    }
  )
}

resource "vyos_config" "service-dns-dynamic-ingress" {
  path = "service dns dynamic interface eth0 service ingress"
  value = jsonencode(
    {
      "host-name" = "ipv4.bjw-s.dev"
      "server"    = "api.cloudflare.com/client/v4"
      "protocol"  = "cloudflare"
      "zone"      = "bjw-s.dev"
      "login"     = "${var.secrets.cloudflare_dyndns_login}"
      "password"  = "${var.secrets.cloudflare_dyndns_token}"
    }
  )
}

resource "vyos_config" "service-dns-dynamic-hardware" {
  path = "service dns dynamic interface eth0 service hardware"
  value = jsonencode(
    {
      "host-name" = "ipv4.bjw-s.tech"
      "server"    = "api.cloudflare.com/client/v4"
      "protocol"  = "cloudflare"
      "zone"      = "bjw-s.tech"
      "login"     = "${var.secrets.cloudflare_dyndns_login}"
      "password"  = "${var.secrets.cloudflare_dyndns_token}"
    }
  )
}
