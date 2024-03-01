terraform {
  cloud {
    organization = "bjw-s"
    hostname = "app.terraform.io"
    workspaces {
      name = "home-s3-provisioner"
    }
  }
}
