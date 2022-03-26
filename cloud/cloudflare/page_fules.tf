resource "cloudflare_page_rule" "plex_bypass_cache" {
  zone_id = cloudflare_zone.zones["personal"].id
  target  = format("plex.%s/*", cloudflare_zone.zones["personal"].zone)
  status  = "active"

  actions {
    cache_level = "bypass"
    disable_performance = true
  }
}
