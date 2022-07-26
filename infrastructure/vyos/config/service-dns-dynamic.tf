resource "vyos_config_block_tree" "service-dns-dynamic" {
  path = "service dns dynamic"

  configs = merge(
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
