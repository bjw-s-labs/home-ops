variable "bucket_name" {
  type = string
}

variable "owner_access_id" {
  type      = string
  sensitive = false
  default   = null
}

variable "owner_secret_key" {
  type      = string
  sensitive = true
  default   = null
}
