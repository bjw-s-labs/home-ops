provider "vyos" {
  alias = "vyos"

  endpoint = "https://gateway.bjw-s.tech:8443"
  api_key  = module.onepassword_item_vyos.fields.api_key
}

provider "remote" {
  alias = "vyos"

  max_sessions = 2

  conn {
    host             = "gateway.bjw-s.tech"
    port             = 22
    user             = module.onepassword_item_vyos.fields.username
    private_key_path = pathexpand("~/.ssh/identities/personal/id_personal")

    sudo = true
  }
}
