terraform {
  required_providers {
    vyos = {
      source  = "Foltik/vyos"
      version = "0.3.2"
    }

    remote = {
      source = "tenstad/remote"
      version = "0.0.24"
    }
  }
}
