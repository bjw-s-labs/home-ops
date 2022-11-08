module "cf_domain_personal" {
  source     = "./modules/cf_domain"
  domain     = local.domains["personal"]
  account_id = cloudflare_account.bjw_s.id
}
