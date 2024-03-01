module "cf_domain_hardware" {
  source     = "./modules/cf_domain"
  domain     = "bjw-s.casa"
  account_id = cloudflare_account.bjw_s.id

  dns_entries = [
    {
      name  = "ipv4"
      value = local.home_ipv4
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
      value   = "key1.bjw-s.casa._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "migadu_dkim_2"
      name    = "key2._domainkey"
      value   = "key2.bjw-s.casa._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "migadu_dkim_3"
      name    = "key3._domainkey"
      value   = "key3.bjw-s.casa._domainkey.migadu.com."
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
      value = "hosted-email-verify=jr49lbxl"
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
      value = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8ogdJ39orzkyWiZyMMFS4IaThlDYUbFh/6yOJ6EujepDWtAV3HbY5MDCfW7e7+pMBvD8PIT88umYwUAwcJe1g86LDVS+DP0xGoNRnWqANqokeUjaxcd2YW1XGloGXm3TL8xs3rPMSD2rOu3aNSLAEUNlHzfOXvhsE46vh/eQv/QIDAQAB"
      type  = "TXT"
    },
    {
      id    = "mailgun_spf"
      name  = "mg"
      value = "v=spf1 include:mailgun.org ~all"
      type  = "TXT"
    },
  ]

  waf_custom_rules = [
    {
      enabled     = true
      description = "Firewall rule to block bots and threats determined by CF"
      expression  = "(cf.client.bot) or (cf.threat_score gt 14)"
      action      = "block"
    },
    {
      enabled     = true
      description = "Firewall rule to block certain countries"
      expression  = "(ip.geoip.country in {\"CN\" \"IN\" \"KP\" \"RU\"})"
      action      = "block"
    },
  ]
}
