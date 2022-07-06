provider "libvirt" {
  uri = "qemu+ssh://serveradmin@libvirt-01.${local.domains.hardware}/system?&no_verify=1"
}
