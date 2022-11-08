# GeoIP blocking

resource "cloudflare_filter" "countries" {
  count = var.enable_default_firewall_rules ? 1 : 0

  zone_id     = cloudflare_zone.zone.id
  description = "Expression to block all countries except NL"
  expression  = "(ip.geoip.country ne \"NL\")"
}

resource "cloudflare_firewall_rule" "countries" {
  count = var.enable_default_firewall_rules ? 1 : 0

  zone_id     = cloudflare_zone.zone.id
  description = "Firewall rule to block all countries except NL"
  filter_id   = cloudflare_filter.countries[count.index].id
  action      = "block"
}

# Bots and threats

resource "cloudflare_filter" "bots_and_threats" {
  count = var.enable_default_firewall_rules ? 1 : 0

  zone_id     = cloudflare_zone.zone.id
  description = "Expression to block bots and threats determined by CF"
  expression  = "(cf.client.bot) or (cf.threat_score gt 14)"
}

resource "cloudflare_firewall_rule" "bots_and_threats" {
  count = var.enable_default_firewall_rules ? 1 : 0

  zone_id     = cloudflare_zone.zone.id
  description = "Firewall rule to block bots and threats determined by CF"
  filter_id   = cloudflare_filter.bots_and_threats[count.index].id
  action      = "block"
}
