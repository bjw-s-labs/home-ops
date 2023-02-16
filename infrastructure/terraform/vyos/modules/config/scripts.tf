resource "remote_file" "scripts-precommit-add_container_images" {
  provider    = remote
  path        = "/config/scripts/commit/pre-hooks.d/add-container-images"
  content     = file(pathexpand("${path.root}/scripts/commit/pre-hooks.d/add-container-images"))
  permissions = "0775"
  owner       = "0"
  group       = "104"
}

resource "remote_file" "scripts-preconfig-bootup" {
  provider = remote
  path     = "/config/scripts/vyos-preconfig-bootup.script"
  content = file(
  pathexpand("${path.root}/scripts/vyos-preconfig-bootup.script"))
  permissions = "0775"
  owner       = "0"
  group       = "104"
}

resource "remote_file" "scripts-custom-config-backup" {
  provider = remote
  path     = "/config/scripts/custom-config-backup.sh"
  content = file(
  pathexpand("${path.root}/scripts/custom-config-backup.sh"))
  permissions = "0775"
  owner       = "0"
  group       = "104"
}
