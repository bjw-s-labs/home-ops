resource "vyos_config_block" "vyos-ssh-keys" {
  for_each = { for key in var.config.ssh.keys : key.name => key }

  path = "system login user vyos authentication public-keys ${each.key}"
  configs = {
    "type" = each.value.type,
    "key"  = sensitive(each.value.key),
  }
}

resource "vyos_config_block_tree" "service-ssh" {
  path = "service ssh"

  configs = {
    "port" = var.config.ssh.port
    # Keep passwords for login via terminal but require key for ssh
    "disable-password-authentication" = var.config.ssh.disable_password_login == true ? "" : null
  }
}
