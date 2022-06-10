module "cf_domain_personal" {
  source = "./cf_domain"
  domain = data.sops_file.cloudflare_secrets.data["cloudflare_zones.personal"]
}

resource "cloudflare_page_rule" "cf_domain_personal_plex_bypass_cache" {
  zone_id = module.cf_domain_personal.zone_id
  target  = format("plex.%s/*", module.cf_domain_personal.zone)
  status  = "active"

  actions {
    cache_level         = "bypass"
    disable_performance = true
  }
}
