module "cf_domain_ingress" {
  source     = "./cf_domain"
  domain     = local.domains["ingress"]
  account_id = cloudflare_account.bjw_s.id
  dns_entries = [
    {
      name  = "ipv4"
      value = local.home_ipv4
    },
    {
      name  = "ingress"
      value = "ipv4.${local.domains["ingress"]}"
      type  = "CNAME"
    },
    {
      name    = "vpn"
      value   = "ipv4.${local.domains["ingress"]}"
      type    = "CNAME"
      proxied = false
    },
    # Generic settings
    {
      name  = "_dmarc"
      value = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s"
      type  = "TXT"
    },
    # Fastmail settings
    {
      id       = "fastmail_mx_1"
      name     = "@"
      priority = 10
      value    = "in1-smtp.messagingengine.com"
      type     = "MX"
    },
    {
      id       = "fastmail_mx_2"
      name     = "@"
      priority = 20
      value    = "in2-smtp.messagingengine.com"
      type     = "MX"
    },
    {
      id      = "fastmail_dkim_1"
      name    = "fm1._domainkey"
      value   = "fm1.${local.domains["ingress"]}.dkim.fmhosted.com"
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "fastmail_dkim_2"
      name    = "fm2._domainkey"
      value   = "fm2.${local.domains["ingress"]}.dkim.fmhosted.com"
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "fastmail_dkim_3"
      name    = "fm3._domainkey"
      value   = "fm3.${local.domains["ingress"]}.dkim.fmhosted.com"
      type    = "CNAME"
      proxied = false
    },
    {
      id    = "fastmail_spf"
      name  = "@"
      value = "v=spf1 include:spf.messagingengine.com ?all"
      type  = "TXT"
    },
    # Mailgun settings
    {
      id       = "mailgun_mx_1"
      name     = "mg"
      priority = 10
      value    = "mxa.eu.mailgun.org"
      type     = "MX"
    },
    {
      id       = "mailgun_mx_2"
      name     = "mg"
      priority = 50
      value    = "mxb.eu.mailgun.org"
      type     = "MX"
    },
    {
      id    = "mailgun_dkim_1"
      name  = "mta._domainkey.mg"
      value = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA01bXkhzb3ANETaXVWO2ODDiakyOoBLS+JfOBqKr70QG40jcUi4QXg2FTWx6pn2fo1enXCm9YIFglSjaJaWp+QBJ9vWIE6ALzKzuE+MKLNSZhaoi8fdGkSM8SC/qXJxcckIpmgVpzA/V89OGZ1rcEKWZqfaSH49KwSyHEWXgZy//G7LQot5NNwPNdJxh9V+nQfd/NxP2qR2t378iX2nE2Rcwgv+mx1ccv73Cy5TeE1+rsag3kTCJTMikB4oJa+tWqr+rav23Z4aYiAZSQyrh/ccQzZGizLtEvZB/OU+IFe36BYdGuBO5N4Ca/rJ/onm72qZcfCmlH1jT0zRBGygxNOQIDAQAB"
      type  = "TXT"
    },
    {
      id    = "mailgun_spf"
      name  = "mg"
      value = "v=spf1 include:mailgun.org ~all"
      type  = "TXT"
    },
  ]
}

resource "cloudflare_filter" "cf_domain_ingress_github_flux_webhook" {
  zone_id     = module.cf_domain_ingress.zone_id
  description = "Allow GitHub flux API"
  expression = format(
    "(ip.geoip.asnum eq 36459 and http.host eq \"flux-receiver-cluster-0.%s\")",
    local.domains["ingress"]
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
