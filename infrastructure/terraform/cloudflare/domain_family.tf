module "cf_domain_family" {
  source     = "./modules/cf_domain"
  domain     = "schorgers.nl"
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
      value   = "key1.schorgers.nl._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "migadu_dkim_2"
      name    = "key2._domainkey"
      value   = "key2.schorgers.nl._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "migadu_dkim_3"
      name    = "key3._domainkey"
      value   = "key3.schorgers.nl._domainkey.migadu.com."
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
      value = "hosted-email-verify=ntxcdcpb"
      type  = "TXT"
    },
  ]
}
