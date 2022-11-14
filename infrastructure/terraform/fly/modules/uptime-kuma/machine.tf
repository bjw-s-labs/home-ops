resource "fly_machine" "machine" {
  for_each = toset(var.regions)
  app      = fly_app.app.name
  region   = each.value

  name  = "${fly_app.app.name}-${each.value}"
  # renovate: docker-image
  image = "louislam/uptime-kuma:1.18.5"

  cpus     = 1
  memorymb = 256

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
      "internal_port" : 3001
    },
  ]

  mounts = [
    {
      path   = "/app/data"
      volume = fly_volume.data[each.value].id
    }
  ]

  depends_on = [
    fly_app.app,
    fly_volume.data
  ]
}
