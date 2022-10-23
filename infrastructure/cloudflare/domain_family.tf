module "cf_domain_family" {
  source     = "./cf_domain"
  domain     = data.sops_file.cloudflare_secrets.data["cloudflare_zones.family"]
  account_id = cloudflare_account.bjw_s.id
}
