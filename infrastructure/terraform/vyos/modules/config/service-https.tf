resource "vyos_config" "service-https" {
  path = "service https"
  value = jsonencode({
    api = {
      debug = {}
      keys = {
        id = {
          terraform = {
            key = var.secrets.terraform_api_key
          }
        }
      }
    }

    virtual-host = {
      default = {
        listen-address = "0.0.0.0"
        listen-port    = "8443"
      }
    }
  })
}
