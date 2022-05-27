resource "remote_file" "scripts-precommit-add_container_images" {
  provider    = remote
  path        = "/config/scripts/commit/pre-hooks.d/add-container-images.sh"
  content     = file(pathexpand("${path.module}/../scripts/commit/pre-hooks.d/add-container-images.sh"))
  permissions = "0755"
}
