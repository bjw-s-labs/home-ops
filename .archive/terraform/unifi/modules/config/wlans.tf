resource "unifi_wlan" "main" {
  name = nonsensitive(var.wlan_main_ssid)
  site = unifi_site.default.name

  security   = "wpapsk"
  passphrase = var.wlan_main_password

  network_id    = unifi_network.trusted.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = data.unifi_user_group.default.id
}

resource "unifi_wlan" "iot" {
  name = nonsensitive(var.wlan_iot_ssid)
  site = unifi_site.default.name

  security   = "wpapsk"
  passphrase = var.wlan_iot_password

  network_id    = unifi_network.iot.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = data.unifi_user_group.default.id

  multicast_enhance = true
}

resource "unifi_wlan" "guest" {
  name = nonsensitive(var.wlan_guest_ssid)
  site = unifi_site.default.name

  security   = "wpapsk"
  passphrase = var.wlan_guest_password

  network_id    = unifi_network.guest.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = data.unifi_user_group.guests.id
}
