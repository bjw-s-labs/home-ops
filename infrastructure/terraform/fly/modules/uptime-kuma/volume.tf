resource "fly_volume" "data" {
  for_each = toset(var.regions)
  app    = fly_app.app.name
  name   = "data_${each.value}"
  size   = 1
  region = each.value

  depends_on = [
    fly_app.app
  ]
}
