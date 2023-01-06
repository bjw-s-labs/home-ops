resource "auth0_user" "bernd" {
  connection_name = auth0_connection.username_password_authentication.name

  name     = var.secrets["users"]["bernd"]["email"]
  nickname = "bernd"
  email    = var.secrets["users"]["bernd"]["email"]
  password = var.secrets["users"]["bernd"]["password"]

  roles = [
    auth0_role.admins.id,
    auth0_role.k8s_admin.id,
    auth0_role.grafana_admin.id,
    auth0_role.calibre_web.id,
    auth0_role.paperless.id,
    auth0_role.miniflux.id,
  ]

  blocked        = false
  email_verified = true
  picture        = "https://s.gravatar.com/avatar/0e840c4607e58c510774bcf301b5b534?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fbe.png"
}

resource "auth0_user" "manyie" {
  connection_name = auth0_connection.username_password_authentication.name

  name     = var.secrets["users"]["manyie"]["email"]
  nickname = "manyie"
  email    = var.secrets["users"]["manyie"]["email"]
  password = var.secrets["users"]["manyie"]["password"]

  roles = [
    auth0_role.calibre_web.id,
    auth0_role.paperless.id,
  ]

  blocked        = false
  email_verified = true
  picture        = "https://s.gravatar.com/avatar/0e840c4607e58c510774bcf301b5b534?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fmf.png"
}
