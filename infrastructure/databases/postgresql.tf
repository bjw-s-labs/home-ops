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
