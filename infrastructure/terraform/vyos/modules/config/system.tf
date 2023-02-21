resource "vyos_config" "system-hostname" {
  path = "system host-name"
  value = jsonencode("gateway")
}

resource "vyos_config" "system-domain_name" {
  path = "system domain-name"
  value = jsonencode("bjw-s.tech")
}

resource "vyos_config" "system-name_server" {
  path = "system name-server"
  value = jsonencode("1.1.1.1")
}

resource "vyos_config" "system-time_zone" {
  path = "system time-zone"
  value = jsonencode("Europe/Amsterdam")
}

resource "vyos_config" "system-task_scheduler" {
  path = "system task-scheduler"
  value = jsonencode({
    "task" = {
      "backup-config" = {
        "crontab-spec" = "30 0 * * *"
        "executable" = {
          "path" = "/config/scripts/custom-config-backup.sh"
        }
      }
    }
  })
}

resource "vyos_config" "system-login-user" {
  path = "system login user"
  value = jsonencode({
    vyos = {
      authentication = {
        encrypted-password = "${var.secrets.vyos_password}"
        plaintext-password = ""

        public-keys = {
          personal = {
            key  = "AAAAC3NzaC1lZDI1NTE5AAAAIMyYn4k4V+myBBl79Nt3t7EZugvz9A+d3ZbKyaP1w7J5"
            type = "ssh-ed25519"
          }

          ios = {
            key  = "AAAAC3NzaC1lZDI1NTE5AAAAINllIKQjpMumg9CCz1HIEsti/cN6MpUWZbCeLiLjKH2W"
            type = "ssh-ed25519"
          }
        }
      }
    }
  })
}
