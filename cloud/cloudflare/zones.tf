resource "cloudflare_zone" "zones" {
  for_each = nonsensitive(yamldecode(data.sops_file.cloudflare_secrets.raw).cloudflare_zones)
  zone = each.value
  plan = "free"
  type = "full"
}
