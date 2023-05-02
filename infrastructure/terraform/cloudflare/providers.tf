provider "cloudflare" {
  email   = module.onepassword_item_cloudflare.fields["username"]
  api_key = module.onepassword_item_cloudflare.fields["api-key"]
}
