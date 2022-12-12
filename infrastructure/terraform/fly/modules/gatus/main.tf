terraform {
  required_providers {
    fly = {
      source = "fly-apps/fly"
    }
  }
}

variable "domains" {
  description = "managed domains"
  type        = any
}

variable "secrets" {
  description = "secrets"
  type        = any
}

variable "regions" {
  description = "Fly regions to deploy machines in"
  type        = list(string)
}
