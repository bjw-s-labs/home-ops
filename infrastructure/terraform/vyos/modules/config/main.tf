terraform {
  required_providers {
    vyos = {
      source  = "TGNThump/vyos"
      version = "1.0.0"
    }

    remote = {
      source  = "tenstad/remote"
      version = "0.1.1"
    }
  }
}
