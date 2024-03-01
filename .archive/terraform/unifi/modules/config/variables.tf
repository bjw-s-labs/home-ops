variable "networks" {
  description = "managed networks"
  type        = any
}

variable "wlan_main_ssid" {
  description = "Main WLAN SSID"
  type        = string
}

variable "wlan_main_password" {
  description = "Main WLAN password"
  type        = string
  sensitive   = true
}

variable "wlan_iot_ssid" {
  description = "IoT WLAN SSID"
  type        = string
}

variable "wlan_iot_password" {
  description = "IoT WLAN password"
  type        = string
  sensitive   = true
}

variable "wlan_guest_ssid" {
  description = "Guest WLAN SSID"
  type        = string
}

variable "wlan_guest_password" {
  description = "Guest WLAN password"
  type        = string
  sensitive   = true
}
