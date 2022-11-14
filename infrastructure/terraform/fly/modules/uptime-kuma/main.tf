terraform {
  required_providers {
    fly = {
      source = "fly-apps/fly"
    }
  }
}

variable "secrets" {
  description = "secrets"
  type        = any
}

variable "regions" {
  description = "Fly regions to deploy machines in"
  type = list(string)
}
