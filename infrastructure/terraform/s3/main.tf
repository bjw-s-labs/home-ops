terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.4"
    }
    garage = {
      source  = "terraform-registry.bjw-s.dev/bjw-s/garage"
      version = "0.0.2"
    }
  }
}
