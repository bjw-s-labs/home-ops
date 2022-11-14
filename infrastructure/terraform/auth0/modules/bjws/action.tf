resource "auth0_action" "add_roles" {
  name    = "add-roles"
  runtime = "node16"
  code    = <<-EOT
        exports.onExecutePostLogin = async (event, api) => {
          const namespace = 'https://bjw-s';
          if (event.authorization) {
            api.idToken.setCustomClaim(`$${namespace}/groups`, event.authorization.roles);
            api.accessToken.setCustomClaim(`$${namespace}/groups`, event.authorization.roles);
          }
        };
    EOT
  deploy  = true

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

resource "auth0_action" "verify_app_access" {
  name    = "verify-app-access"
  runtime = "node16"
  code    = <<-EOT
        exports.onExecutePostLogin = async (event, api) => {
          // Miniflux does not support OIDC authorization, only authentication
          if (event.client.name === "${auth0_client.miniflux.name}" && !event.authorization.roles.includes("miniflux")) {
            api.access.deny(`Access to $${event.client.name} is not allowed.`);
          }
        };
    EOT
  deploy  = true

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

resource "auth0_trigger_binding" "login_flow" {
  trigger = "post-login"

  actions {
    display_name = "verify-app-access"
    id           = auth0_action.verify_app_access.id
  }

  actions {
    display_name = "add-roles"
    id           = auth0_action.add_roles.id
  }
}
