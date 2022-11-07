resource "cloudflare_account" "bjw_s" {
  name              = "bjw-s's Account"
  type              = "standard"
  enforce_twofactor = false
}
