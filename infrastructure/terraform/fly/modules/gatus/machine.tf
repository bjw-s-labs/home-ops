resource "fly_machine" "machine" {
  for_each = toset(var.regions)
  app      = fly_app.app.name
  region   = each.value

  name = "${fly_app.app.name}-${each.value}"
  # renovate: docker-image
  image = "ghcr.io/bjw-s/gatus:5.3.0"

  cpus     = 1
  memorymb = 256

  env = {
    GATUS_CONFIG_BASE64 = base64encode(yamlencode(local.gatus_config)),
    TINI_SUBREAPER      = "true"
  }

  services = [
    {
      ports = [
        {
          port     = 443
          handlers = ["tls", "http"]
        },
        {
          port     = 80
          handlers = ["http"]
        }
      ]
      "protocol" : "tcp",
      "internal_port" : 8080
    },
  ]

  depends_on = [
    fly_app.app,
    fly_ip.ipv4
  ]
}
