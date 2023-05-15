locals {
  switch_core_1_name       = "Switch - Core 1"
  switch_core_2_name       = "Switch - Core 2"
  switch_media_name        = "Switch - Media"
  ap_attic_office_name     = "AP - Attic Office"
  ap_hallway_name          = "AP - Hallway"
  ap_upstairs_hallway_name = "AP - Upstairs Hallway"
  ap_garage_name           = "AP - Garage"
}

resource "unifi_device" "switch_core_1" {
  mac  = "70:a7:41:f3:c8:92"
  name = local.switch_core_1_name
  site = unifi_site.default.name

  port_override {
    number          = 1
    name            = unifi_device.ap_hallway.name
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 2
    name            = local.switch_media_name
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 3
    name            = "hallway_zigbee_adapter"
    port_profile_id = data.unifi_port_profile.iot.id
  }
  port_override {
    number          = 4
    name            = "hallway_tado_bridge"
    port_profile_id = data.unifi_port_profile.iot.id
  }
  port_override {
    number          = 5
    name            = "driveway_camera_doorbell"
    port_profile_id = data.unifi_port_profile.video.id
  }
  port_override {
    number          = 6
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 7
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 8
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 9
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 10
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 11
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 12
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 13
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 14
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 15
    name            = local.switch_core_2_name
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 16
    port_profile_id = data.unifi_port_profile.all.id
  }
}

resource "unifi_device" "switch_core_2" {
  mac  = "68:d7:9a:3c:b0:75"
  name = local.switch_core_2_name
  site = unifi_site.default.name

  port_override {
    number          = 1
    name            = local.switch_core_1_name
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 2
    name            = unifi_device.ap_garage.name
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 3
    name            = unifi_device.ap_attic_office.name
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 4
    name            = unifi_device.ap_upstairs_hallway.name
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 5
    name            = "attic_office_hue_bridge"
    port_profile_id = data.unifi_port_profile.iot.id
  }
  port_override {
    number          = 6
    name            = "diego"
    port_profile_id = data.unifi_port_profile.servers.id
  }
  port_override {
    number          = 7
    name            = "horus"
    port_profile_id = data.unifi_port_profile.servers.id
  }
  port_override {
    number          = 8
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 9
    name            = "delta"
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 10
    name            = "vyos_router"
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 11
    name            = "enigma"
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 12
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 13
    name            = "felix"
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 14
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number              = 15
    name                = "nas"
    port_profile_id     = data.unifi_port_profile.servers.id
    op_mode             = "aggregate"
    aggregate_num_ports = 2
  }
  # port_override {
  #   number          = 16
  #   name            = "nas"
  #   port_profile_id = data.unifi_port_profile.servers.id
  # }
}

resource "unifi_device" "switch_media" {
  mac  = "74:83:c2:0c:19:90"
  name = local.switch_media_name
  site = unifi_site.default.name

  port_override {
    number          = 1
    name            = local.switch_core_1_name
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 2
    name            = "livingroom_shield"
    port_profile_id = unifi_port_profile.iot_poe_disabled.id
  }
  port_override {
    number          = 3
    name            = "livingroom_receiver"
    port_profile_id = unifi_port_profile.iot_poe_disabled.id
  }
  port_override {
    number          = 4
    port_profile_id = data.unifi_port_profile.all.id
  }
  port_override {
    number          = 5
    port_profile_id = data.unifi_port_profile.all.id
  }
}

resource "unifi_device" "ap_hallway" {
  mac  = "44:d9:e7:fc:21:f9"
  name = local.ap_hallway_name
  site = unifi_site.default.name
}

resource "unifi_device" "ap_upstairs_hallway" {
  mac  = "e0:63:da:ac:d4:3e"
  name = local.ap_upstairs_hallway_name
  site = unifi_site.default.name
}

resource "unifi_device" "ap_garage" {
  mac  = "fc:ec:da:b6:27:87"
  name = local.ap_garage_name
  site = unifi_site.default.name
}

resource "unifi_device" "ap_attic_office" {
  mac  = "80:2a:a8:d3:0b:b3"
  name = local.ap_attic_office_name
  site = unifi_site.default.name
}
