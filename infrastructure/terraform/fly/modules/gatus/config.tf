data "fly_app" "app" {
  name = fly_app.app.name
  depends_on = [
    fly_app.app
  ]
}

locals {
  gatus_config = {
    "security" : {
      "oidc" : {
        "issuer-url" : var.secrets.gatus.oidc.issuer_url
        "redirect-url" : "https://status.${var.domains["ingress"]}/authorization-code/callback"
        "client-id" : var.secrets.gatus.oidc.client_id
        "client-secret" : var.secrets.gatus.oidc.client_secret
        "scopes" : ["openid"]
        "allowed-subjects" : var.secrets.gatus.oidc.subjects
      }
    }

    "alerting": {
      "custom": {
        "url": "https://api.pushover.net/1/messages.json"
        "method": "POST"
        "body": "token=${var.secrets.gatus.pushover.token}&user=${var.secrets.gatus.pushover.user_key}&title=[ALERT_TRIGGERED_OR_RESOLVED]:+[ENDPOINT_GROUP]+-+[ENDPOINT_NAME]&message=[ALERT_DESCRIPTION]"
        "default-alert": {
          "description": "Healthcheck failed"
          "failure-threshold": 2
          "success-threshold": 2
          "send-on-resolved": true
        }
      }
    }

    "endpoints" : [
      {
        "name" : "home internet reachability"
        "group" : "core"
        "url" : "tcp://ipv4.${var.domains.ingress}:443"
        "interval" : "30s"
        "conditions" : [
          "[CONNECTED] == true"
        ],
        "alerts": [
          {"type": "custom"}
        ]
      },

      {
        "name" : "home assistant"
        "group" : "services"
        "url" : "https://domo.${var.domains.ingress}"
        "interval" : "5m"
        "conditions" : [
          "[CONNECTED] == true",
          "[STATUS] == 200"
        ],
        "alerts": [
          {"type": "custom"}
        ]
      },
      {
        "name" : "plex"
        "group" : "services"
        "url" : "https://plex.${var.domains.ingress}/web/index.html"
        "interval" : "5m"
        "conditions" : [
          "[CONNECTED] == true",
          "[STATUS] == 200"
        ],
        "alerts": [
          {"type": "custom"}
        ]
      },
      {
        "name" : "navidrome"
        "group" : "services"
        "url" : "https://navidrome.${var.domains.ingress}/app"
        "interval" : "5m"
        "conditions" : [
          "[CONNECTED] == true",
          "[STATUS] == 200"
        ],
        "alerts": [
          {"type": "custom"}
        ]
      },
    ]
  }
}
