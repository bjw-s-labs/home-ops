resource "vyos_config" "service-dns-dynamic" {
  path = "service dns dynamic"
  value = jsonencode(
    {
      "interface" = {
        "eth0" = {
          "service" = merge([
            for domain in ["family", "personal", "ingress"] : {
              "${domain}" = {
                "host-name" = "ipv4.${var.domains[domain]}"
                "server"    = "api.cloudflare.com/client/v4"
                "protocol"  = "cloudflare"
                "zone"      = "${var.domains[domain]}"
                "login"     = "${var.secrets.cloudflare.login}"
                "password"  = "${var.secrets.cloudflare.key}"
              }
            }
          ]...)
        }
      }
    }
  )
}
