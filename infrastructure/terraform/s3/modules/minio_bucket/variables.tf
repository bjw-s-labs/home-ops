variable "bucket_name" {
  type = string
}

variable "user_name" {
  type      = string
  sensitive = false
  default   = null
}

variable "user_secret" {
  type      = string
  sensitive = true
  default   = null
}
