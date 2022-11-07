resource "vyos_config_block_tree" "service-dns-dynamic" {
  path = "service dns dynamic"

  configs = merge(
    {
      "interface eth0 service vpn host-name" = "vpn.${var.domains["ingress"]}"
      "interface eth0 service vpn server"    = "api.cloudflare.com/client/v4"
      "interface eth0 service vpn protocol"  = "cloudflare"
      "interface eth0 service vpn zone"      = "${var.domains["ingress"]}"
      "interface eth0 service vpn login"     = "${var.secrets.cloudflare.login}"
      "interface eth0 service vpn password"  = "${var.secrets.cloudflare.key}"
    },

    merge([
      for domain in ["family", "personal", "ingress"] : {
        "interface eth0 service ${domain} host-name" = "gateway.${var.domains[domain]}"
        "interface eth0 service ${domain} server"    = "api.cloudflare.com/client/v4"
        "interface eth0 service ${domain} protocol"  = "cloudflare"
        "interface eth0 service ${domain} zone"      = "${var.domains[domain]}"
        "interface eth0 service ${domain} login"     = "${var.secrets.cloudflare.login}"
        "interface eth0 service ${domain} password"  = "${var.secrets.cloudflare.key}"
      }
    ]...),
  )
}
