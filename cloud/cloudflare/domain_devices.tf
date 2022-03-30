module "cf_domain_devices" {
  source = "./cf_domain"
  domain = data.sops_file.cloudflare_secrets.data["cloudflare_zones.devices"]
}
