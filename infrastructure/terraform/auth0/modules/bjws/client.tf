resource "auth0_client" "default" {
  name = "your app"

  allowed_clients     = []
  allowed_logout_urls = []
  allowed_origins     = []
  callbacks = [
    "https://auth.${var.domains["ingress"]}/oauth2/callback",          # oauth2-proxy
    "https://grafana.${var.domains["ingress"]}/login/generic_oauth",   # Grafana
    "http://localhost:8000",                                           # kubectl oidc-login
    "https://bjw-s-gatus.fly.dev/authorization-code/callback",         # Gatus
  ]

  client_aliases       = []
  client_metadata      = {}
  cross_origin_auth    = false
  custom_login_page_on = true

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
    "client_credentials",
  ]
  oidc_conformant = true

  sso = true

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
    scopes              = {}
    secret_encoded      = false
  }

  native_social_login {
    apple {
      enabled = false
    }

    facebook {
      enabled = false
    }
  }
}

resource "auth0_client" "miniflux" {
  name = "Miniflux"

  allowed_clients     = []
  allowed_logout_urls = []
  allowed_origins     = []
  callbacks = [
    "https://miniflux.${var.domains["ingress"]}/oauth2/oidc/callback"
  ]

  client_aliases       = []
  client_metadata      = {}
  cross_origin_auth    = false
  custom_login_page_on = true

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
    "client_credentials",
  ]
  oidc_conformant = true

  sso = true

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
    scopes              = {}
    secret_encoded      = false
  }

  native_social_login {
    apple {
      enabled = false
    }

    facebook {
      enabled = false
    }
  }
}
