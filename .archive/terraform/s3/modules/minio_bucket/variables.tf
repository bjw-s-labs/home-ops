variable "bucket_name" {
  type = string
}

variable "is_public" {
  type = bool
  default = false
}

variable "owner_access_key" {
  type      = string
  sensitive = false
  default   = null
}

variable "owner_secret_key" {
  type      = string
  sensitive = true
  default   = null
}
