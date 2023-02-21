resource "vyos_config" "nat" {
  path = "nat"
  value = jsonencode(
    {
      # Source NAT
      source = {
        rule = {
          "100" = {
            description = "LAN -> WAN"
            destination = {
              address = "0.0.0.0/0"
            }
            outbound-interface = "eth0"
            translation = {
              address = "masquerade"
            }
          }
        }
      }

      # Destination NAT
      destination = {
        rule = {
          # Forward HTTP / HTTPS to ingress
          "100" = {
            description = "HTTPS"
            destination = {
              port = "443"
            }
            inbound-interface = "eth0"
            protocol          = "tcp"
            translation = {
              address = "10.45.0.1"
              port    = "443"
            }
          }
          "101" = {
            description = "HTTP"
            destination = {
              port = "80"
            }
            inbound-interface = "eth0"
            protocol          = "tcp"
            translation = {
              address = "10.45.0.1"
              port    = "80"
            }
          }

          # Force DNS to dnsdist
          "102" = {
            description = "Force DNS for IoT"
            destination = {
              address = "!10.5.0.4"
              port    = "53"
            }
            inbound-interface = "eth1.40"
            protocol          = "tcp_udp"
            translation = {
              address = "10.5.0.4"
              port    = "53"
            }
          }
          "103" = {
            description = "Force DNS for Video"
            destination = {
              address = "!10.5.0.4"
              port    = "53"
            }
            inbound-interface = "eth1.50"
            protocol          = "tcp_udp"
            translation = {
              address = "10.5.0.4"
              port    = "53"
            }
          }

          # Force NTP
          "104" = {
            description = "Force NTP for LAN"
            destination = {
              address = "!10.1.0.1"
              port    = "123"
            }
            inbound-interface = "eth1"
            protocol          = "udp"
            translation = {
              address = "10.1.0.1"
              port    = "123"
            }
          }
          "105" = {
            description = "Force NTP for Servers"
            destination = {
              address = "!10.1.1.1"
              port    = "123"
            }
            inbound-interface = "eth1.10"
            protocol          = "udp"
            translation = {
              address = "10.1.1.1"
              port    = "123"
            }
          }
          "106" = {
            description = "Force NTP for Trusted"
            destination = {
              address = "!10.1.2.1"
              port    = "123"
            }
            inbound-interface = "eth1.20"
            protocol          = "udp"
            translation = {
              address = "10.1.2.1"
              port    = "123"
            }
          }
          "107" = {
            description = "Force NTP for IoT"
            destination = {
              address = "!10.1.3.1"
              port    = "123"
            }
            inbound-interface = "eth1.40"
            protocol          = "udp"
            translation = {
              address = "10.1.3.1"
              port    = "123"
            }
          }
          "108" = {
            description = "Force NTP for Video"
            destination = {
              address = "!10.1.4.1"
              port    = "123"
            }
            inbound-interface = "eth1.50"
            protocol          = "udp"
            translation = {
              address = "10.1.4.1"
              port    = "123"
            }
          }
          "109" = {
            description = "Force NTP for Wireguard Trusted"
            destination = {
              address = "!10.0.11.1"
              port    = "123"
            }
            inbound-interface = "wg01"
            protocol          = "udp"
            translation = {
              address = "10.0.11.1"
              port    = "123"
            }
          }
        }
      }
    }
  )

  depends_on = [
    vyos_config.interface-wan,
    vyos_config.interface-lan
  ]
}
