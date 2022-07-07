resource "random_uuid" "docker_01_volume" {
  keepers = {
    libvirt_ignition = "${sensitive(libvirt_ignition.docker_01_core_os_config.content)}"
  }
}

resource "libvirt_pool" "cluster" {
  name = "cluster"
  type = "dir"
  path = "/var/libvirt/cluster_storage"
}

resource "libvirt_pool" "images" {
  name = "images"
  type = "dir"
  path = "/var/libvirt/images"
}

resource "libvirt_volume" "fedora-coreos" {
  name             = "fedora-coreos-${local.settings.coreos.version}-qemu.x86_64.qcow2"
  pool             = libvirt_pool.images.name
  format           = "qcow2"
  base_volume_name = "fedora-coreos-${local.settings.coreos.version}-qemu.x86_64.qcow2"
}

resource "libvirt_volume" "docker_01_fcos" {
  name             = "fcos-base-${random_uuid.docker_01_volume.id}.qcow2"
  pool             = libvirt_pool.cluster.name
  format           = "qcow2"
  size             = "20442450944"
  base_volume_name = libvirt_volume.fedora-coreos.name
  base_volume_pool = libvirt_pool.images.name
}

resource "libvirt_volume" "docker_01_persist" {
  name   = "docker-01-var-srv.qcow2"
  pool   = libvirt_pool.cluster.name
  format = "qcow2"
  size   = "53687091200"
}

data "ct_config" "docker_01" {
  content = templatefile(
    "ignition.yaml",
    {
      hostname = local.settings.hostname
      nas = "nas.${local.domains.hardware}"
      postgres = {
        image    = local.settings.containers.postgres.image
        password = data.sops_file.vm_secrets.data["postgres.postgres_password"]
      }
      postgres_backup = local.settings.containers.postgres_backup
    }
  )
  strict       = true
  pretty_print = true
}

resource "libvirt_ignition" "docker_01_core_os_config" {
  name    = "docker-01-ignition"
  pool    = libvirt_pool.cluster.name
  content = data.ct_config.docker_01.rendered
}

resource "libvirt_domain" "docker_01" {
  name        = local.settings.hostname
  description = "Docker container node"
  vcpu        = "2"
  memory      = "8192"
  qemu_agent  = true
  autostart   = true
  running     = true
  console {
    type        = "pty"
    target_port = "0"
  }
  disk {
    volume_id = libvirt_volume.docker_01_fcos.id
  }
  disk {
    volume_id = libvirt_volume.docker_01_persist.id
  }
  network_interface {
    bridge   = "br0"
    mac      = "52:54:00:b2:2f:86"
    hostname = local.settings.hostname
  }
  coreos_ignition = libvirt_ignition.docker_01_core_os_config.id
}
