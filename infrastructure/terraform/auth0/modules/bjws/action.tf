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

resource "auth0_trigger_binding" "login_flow" {
  trigger = "post-login"

  actions {
    display_name = "add-roles"
    id           = "a5335507-86e1-4e56-9e73-d138f2bb4999"
  }
}
