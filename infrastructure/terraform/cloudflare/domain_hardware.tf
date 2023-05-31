module "cf_domain_hardware" {
  source     = "./modules/cf_domain"
  domain     = "bjw-s.tech"
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
    # Fastmail settings
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
      value   = "key1.bjw-s.tech._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "migadu_dkim_2"
      name    = "key2._domainkey"
      value   = "key2.bjw-s.tech._domainkey.migadu.com."
      type    = "CNAME"
      proxied = false
    },
    {
      id      = "migadu_dkim_3"
      name    = "key3._domainkey"
      value   = "key3.bjw-s.tech._domainkey.migadu.com."
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
      value = "hosted-email-verify=7qqry92a"
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
      name  = "s1._domainkey.mg"
      value = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqQppZfQxBBxP3YU0WY14uo+s/pNomR6XP/OBy7Q5MXdd/bHf5/q/THXhVhek2DDMa2BiqTaaXbx0vR18YAKpU96mA0l1ot7dyX0G4nSOST7UO0EvqUxZLzPAl+eYhCGAlJWeZqWTzMqWpjNA2xYbqOOA5wFZ9L3BtC4VNJl8hnIRcGogLOUp7+q8u3D8hsPsAN5Hf6v8SaBRXoLn/r+CUwOqjEFoaRhH/37C5EnWWQ0zWbRQa4jv1meJBpoTnfN7jpAPTQddCBFPBap1UCVfXxEk7EtVYBwx+rAhz9nO4BvzYcE2Z5r1r7QcND/0oeCivAjT1Wt3oxb5VvHm38OJrwIDAQAB"
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
