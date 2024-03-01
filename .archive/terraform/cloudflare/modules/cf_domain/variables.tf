variable "account_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "enable_default_firewall_rules" {
  type    = bool
  default = true
}

variable "dns_entries" {
  type = list(object({
    id       = optional(string)
    name     = string,
    value    = string,
    type     = optional(string, "A"),
    proxied  = optional(bool, true),
    priority = optional(number, 0),
    ttl      = optional(number, 1)
  }))
  default = []
}

variable "waf_custom_rules" {
  type = list(object({
    enabled           = bool
    description       = string
    expression        = string
    action            = string
    action_parameters = optional(any, {})
    logging           = optional(any, {})
  }))
  default = []
}
