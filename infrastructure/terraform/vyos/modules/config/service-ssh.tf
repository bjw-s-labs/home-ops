resource "vyos_config" "service-ssh" {
  path = "service ssh"
  value = jsonencode({
    "port"                            = "22"
    "disable-password-authentication" = {}
  })
}
