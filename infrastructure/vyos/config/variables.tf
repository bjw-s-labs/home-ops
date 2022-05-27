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
