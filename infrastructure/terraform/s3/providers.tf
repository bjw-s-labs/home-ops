provider "garage" {
  alias  = "nas"
  host   = "garage.bjw-s.dev"
  scheme = "https"
  token  = module.onepassword_item_garage.fields.admin_api_token
}
