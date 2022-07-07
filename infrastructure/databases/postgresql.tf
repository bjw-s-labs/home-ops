resource "postgresql_role" "dsmr-reader" {
  name            = "dsmr-reader"
  login           = true
  password        = data.sops_file.database_secrets.data["postgres.roles.dsmr-reader.password"]
}

resource "postgresql_database" "dsmr-reader" {
  name              = "dsmr-reader"
  owner             = "dsmr-reader"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
  depends_on = [postgresql_role.dsmr-reader]
}

resource "postgresql_role" "miniflux" {
  name            = "miniflux"
  login           = true
  password        = data.sops_file.database_secrets.data["postgres.roles.miniflux.password"]
}

resource "postgresql_database" "miniflux" {
  name              = "miniflux"
  owner             = "miniflux"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
  depends_on = [postgresql_role.miniflux]
}

resource "postgresql_role" "home-assistant" {
  name            = "home-assistant"
  login           = true
  password        = data.sops_file.database_secrets.data["postgres.roles.home-assistant.password"]
}

resource "postgresql_database" "home-assistant" {
  name              = "home-assistant"
  owner             = "home-assistant"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
  depends_on = [postgresql_role.home-assistant]
}
