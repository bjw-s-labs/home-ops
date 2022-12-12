resource "fly_ip" "ipv4" {
  app  = fly_app.app.name
  type = "v4"
  depends_on = [
    fly_app.app
  ]
}
