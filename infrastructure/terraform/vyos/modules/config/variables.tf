variable "config" {
  description = "vyos module config"
  type        = any
}

variable "networks" {
  description = "vyos networks"
  type        = any
}

variable "domains" {
  description = "managed domains"
  type        = any
}

variable "address_book" {
  description = "address book"
  type        = any
}

variable "firewall_rules" {
  description = "firewall rules"
  type        = any
}

variable "secrets" {
  description = "secrets"
  type        = any
}
