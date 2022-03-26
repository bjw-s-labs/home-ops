#
# GeoIP blocking
#

resource "cloudflare_filter" "countries" {
  for_each = cloudflare_zone.zones
  zone_id     = each.value.id
  description = "Expression to block all countries except NL"
  expression  = "(ip.geoip.country ne \"NL\")"
}

resource "cloudflare_firewall_rule" "countries" {
  for_each = cloudflare_filter.countries
  zone_id     = cloudflare_zone.zones[each.key].id
  description = "Firewall rule to block all countries except NL"
  filter_id   = each.value.id
  action      = "block"
}

#
# Allow GitHub flux API
#

resource "cloudflare_filter" "gh_flux_api" {
  zone_id     = cloudflare_zone.zones["ingress"].id
  description = "Expression to allow GitHub flux API"
  expression  = format(
    "(ip.geoip.asnum eq 36459 and http.host eq \"flux-receiver-cluster-0.%s\")",
    cloudflare_zone.zones["ingress"].zone
  )
}

resource "cloudflare_firewall_rule" "gh_flux_api" {
  zone_id     = cloudflare_zone.zones["ingress"].id
  description = "Firewall rule to allow GitHub flux API"
  filter_id   = cloudflare_filter.gh_flux_api.id
  action      = "allow"
}

#
# Bots and threats
#

resource "cloudflare_filter" "bots_and_threats" {
  for_each = cloudflare_zone.zones
  zone_id     = each.value.id
  description = "Expression to block bots and threats determined by CF"
  expression  = "(cf.client.bot) or (cf.threat_score gt 14)"
}

resource "cloudflare_firewall_rule" "bots_and_threats" {
  for_each = cloudflare_filter.bots_and_threats
  zone_id     = cloudflare_zone.zones[each.key].id
  description = "Firewall rule to block bots and threats determined by CF"
  filter_id   = each.value.id
  action      = "block"
}
