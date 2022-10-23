module "cf_domain_personal" {
  source     = "./cf_domain"
  domain     = data.sops_file.cloudflare_secrets.data["cloudflare_zones.personal"]
  account_id = cloudflare_account.bjw_s.id
}
