provider "postgresql" {
  host            = "vm-docker-01.${local.domains.hardware}"
  port            = 5432
  database        = "postgres"
  username        = "postgres"
  password        = data.sops_file.database_secrets.data["postgres.postgres_password"]
  sslmode         = "disable"
  connect_timeout = 90000000
}
