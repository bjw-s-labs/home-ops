module "cf_domain_hardware" {
  source     = "./modules/cf_domain"
  domain     = local.domains["hardware"]
  account_id = cloudflare_account.bjw_s.id
}
