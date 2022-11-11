resource "vyos_config" "vyos-ssh-keys" {
  for_each = { for key in var.config.ssh.keys : key.name => key }

  path = "system login user vyos authentication public-keys ${each.key}"
  value = jsonencode({
    "type" = each.value.type,
    "key"  = sensitive(each.value.key),
  })
}

resource "vyos_config" "service-ssh" {
  path = "service ssh"
  value = jsonencode(
    merge(
      {
        "port" = tostring(var.config.ssh.port)
      },
      var.config.ssh.disable_password_login != true ? {} : {
        # Keep passwords for login via terminal but require key for ssh
        "disable-password-authentication" = {}
      }
    )
  )
}
