resource "cloudflare_ruleset" "waf_custom_rules" {
  zone_id = cloudflare_zone.zone.id
  name    = "Zone custom WAF ruleset"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  dynamic "rules" {
    for_each = var.waf_custom_rules
    iterator = rule
    content {
      enabled     = rule.value.enabled
      description = rule.value.description
      expression  = rule.value.expression
      action      = rule.value.action

      dynamic "logging" {
        for_each = length(keys(rule.value.logging)) > 0 ? [true] : []
        content {
          enabled = lookup(rule.value.logging, "enabled", null)
        }
      }

      dynamic "action_parameters" {
        for_each = length(keys(rule.value.action_parameters)) > 0 ? [true] : []
        content {
          ruleset = lookup(rule.value.action_parameters, "ruleset", null)
        }
      }
    }
  }
}
