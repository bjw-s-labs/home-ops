locals {
  config = {
    hostname             = "gateway"
    domain_name          = data.sops_file.vyos_secrets.data["domain_name"]
    upstream_name_server = "1.1.1.1"
    time_zone            = "Europe/Amsterdam"

    api = {
      listen_address = "0.0.0.0"
      port           = 8443
      keys = {
        terraform = data.sops_file.vyos_secrets.data["api.key"]
      }
    }

    ssh = {
      port                   = 22
      disable_password_login = true
      keys                   = yamldecode(data.sops_file.vyos_secrets.raw).ssh.keys
    }

    interfaces = {
      wan = {
        interface   = "eth0"
        router_cidr = "dhcp"
      }

      lan = {
        interface   = "eth1"
        router_cidr = "${cidrhost(local.networks.lan, 1)}/24"
        vlans = {
          servers = {
            vlan_id     = 10
            router_cidr = "${cidrhost(local.networks.servers, 1)}/24"
          }

          trusted = {
            vlan_id     = 20
            router_cidr = "${cidrhost(local.networks.trusted, 1)}/24"
          }

          guest = {
            vlan_id     = 30
            router_cidr = "${cidrhost(local.networks.guest, 1)}/24"
          }

          iot = {
            vlan_id     = 40
            router_cidr = "${cidrhost(local.networks.iot, 1)}/24"
          }

          video = {
            vlan_id     = 50
            router_cidr = "${cidrhost(local.networks.video, 1)}/24"
          }
        }
      }

      rescue = {
        interface   = "eth2"
        router_cidr = "${cidrhost(local.networks.rescue, 1)}/24"
      }
    }
  }

  networks = {
    lan        = "10.1.0.0/24"
    servers    = "10.1.1.0/24"
    trusted    = "10.1.2.0/24"
    guest      = "192.168.2.0/24"
    iot        = "10.1.3.0/24"
    video      = "10.1.4.0/24"
    wg_trusted = "10.0.11.0/24"
    services   = "10.5.0.0/24"
    rescue     = "192.168.15.0/24"
  }
}
