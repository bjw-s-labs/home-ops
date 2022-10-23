module "cf_domain_ingress" {
  source     = "./cf_domain"
  domain     = data.sops_file.cloudflare_secrets.data["cloudflare_zones.ingress"]
  account_id = cloudflare_account.bjw_s.id
}

resource "cloudflare_filter" "cf_domain_ingress_github_flux_webhook" {
  zone_id     = module.cf_domain_ingress.zone_id
  description = "Allow GitHub flux API"
  expression = format(
    "(ip.geoip.asnum eq 36459 and http.host eq \"flux-receiver-cluster-0.%s\")",
    data.sops_file.cloudflare_secrets.data["cloudflare_zones.ingress"]
  )
}

resource "cloudflare_firewall_rule" "cf_domain_ingress_github_flux_webhook" {
  zone_id     = module.cf_domain_ingress.zone_id
  description = "Allow GitHub flux API"
  filter_id   = cloudflare_filter.cf_domain_ingress_github_flux_webhook.id
  action      = "allow"
  priority    = 1
}

resource "cloudflare_page_rule" "cf_domain_ingress_navidrome_bypass_cache" {
  zone_id  = module.cf_domain_ingress.zone_id
  target   = format("navidrome.%s/*", module.cf_domain_ingress.zone)
  status   = "active"
  priority = 2

  actions {
    cache_level         = "bypass"
    disable_performance = true
  }
}

resource "cloudflare_page_rule" "cf_domain_ingress_plex_bypass_cache" {
  zone_id  = module.cf_domain_ingress.zone_id
  target   = format("plex.%s/*", module.cf_domain_ingress.zone)
  status   = "active"
  priority = 1

  actions {
    cache_level         = "bypass"
    disable_performance = true
  }
}
