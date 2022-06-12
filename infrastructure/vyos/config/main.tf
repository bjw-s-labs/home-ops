terraform {
  required_providers {
    vyos = {
      source  = "Foltik/vyos"
      version = "0.3.3"
    }

    remote = {
      source  = "tenstad/remote"
      version = "0.1.0"
    }
  }
}
