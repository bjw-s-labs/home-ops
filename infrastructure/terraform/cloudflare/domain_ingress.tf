module "cf_domain_ingress" {
  source     = "./modules/cf_domain"
  domain     = "bjw-s.dev"
  account_id = cloudflare_account.bjw_s.id
  dns_entries = [
    {
      name  = "ipv4"
      value = local.home_ipv4
    },
    {
      id      = "vpn"
      name    = module.onepassword_item_cloudflare.fields["vpn-subdomain"]
      value   = "ipv4.bjw-s.dev"
      type    = "CNAME"
      proxied = false
    },
    # Generic settings
    {
      name  = "_dmarc"
      value = "v=DMARC1; p=quarantine;"
      type  = "TXT"
    },
    # Migadu settings
    {
      id       = "migadu_mx_1"
      name     = "@"
      priority = 10
      value    = "aspmx1.migadu.com"
      type     = "MX"
    },
    {
      id       = "migadu_mx_2"
      name     = "@"
      priority = 20
      value    = "aspmx2.migadu.com"
      type     = "MX"
    },
    {
      id      = "migadu_dkim_1"
      name    = "key1._domainkey"
      value   = "key1.bjw-s.dev._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "migadu_dkim_2"
      name    = "key2._domainkey"
      value   = "key2.bjw-s.dev._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "migadu_dkim_3"
      name    = "key3._domainkey"
      value   = "key3.bjw-s.dev._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id    = "migadu_spf"
      name  = "@"
      value = "v=spf1 include:spf.migadu.com -all"
      type  = "TXT"
    },
    {
      id    = "migadu_verification"
      name  = "@"
      value = "hosted-email-verify=sjpcto0x"
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
    }
  ]

  waf_custom_rules = [
    {
      enabled     = true
      description = "Allow Migadu access to Radicale"
      expression  = "(ip.geoip.country ne \"FR\") and (ip.geoip.asnum eq 36459) and (http.host eq \"flux-receiver-cluster-0.bjw-s.dev\")"
      action      = "skip"
      action_parameters = {
        ruleset = "current"
      }
      logging = {
        enabled = false
      }
    },
    {
      enabled     = true
      description = "Allow GitHub flux API"
      expression  = "(ip.geoip.asnum eq 16276 and http.host eq \"radicale.bjw-s.dev\")"
      action      = "skip"
      action_parameters = {
        ruleset = "current"
      }
      logging = {
        enabled = false
      }
    },
    {
      enabled     = true
      description = "Firewall rule to block bots and threats determined by CF"
      expression  = "(cf.client.bot) or (cf.threat_score gt 14)"
      action      = "block"
    },
    {
      enabled     = true
      description = "Firewall rule to block all countries except NL/BE/DE"
      expression  = "(ip.geoip.country ne \"NL\") and (ip.geoip.country ne \"BE\") and (ip.geoip.country ne \"DE\")"
      action      = "block"
    },
    {
      enabled     = true
      description = "Block Plex notifications"
      expression  = "(http.host eq \"plex.bjw-s.dev\" and http.request.uri.path contains \"/:/eventsource/notifications\")"
      action      = "block"
    },
  ]
}
