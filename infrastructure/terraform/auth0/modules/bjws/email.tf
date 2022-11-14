resource "auth0_email" "mailgun_provider" {
  name    = "mailgun"
  enabled = true

  default_from_address = "bjw-s authentication <noreply@mg.${var.domains["ingress"]}>"

  credentials {
    domain    = "mg.${var.domains["ingress"]}"
    region    = "eu"
    smtp_port = 0
    api_key = var.secrets["mailgun"]["api_key"]
  }
}
