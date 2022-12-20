resource "auth0_connection" "username_password_authentication" {
  name                 = "Username-Password-Authentication"
  is_domain_connection = false
  strategy             = "auth0"

  metadata = {}
  realms = [
    "Username-Password-Authentication",
  ]

  options {
    allowed_audiences              = []
    api_enable_users               = false
    auth_params                    = {}
    brute_force_protection         = true
    custom_scripts                 = {}
    debug                          = false
    disable_cache                  = false
    disable_sign_out               = false
    disable_signup                 = true
    domain_aliases                 = []
    enabled_database_customization = false
    forward_request_info           = false
    import_mode                    = false
    ips                            = []
    non_persistent_attrs           = []
    password_policy                = "good"
    pkce_enabled                   = false
    requires_username              = false
    scopes                         = []
    scripts                        = {}
    sign_saml_request              = false
    strategy_version               = 0
    use_cert_auth                  = false
    use_kerberos                   = false
    use_wsfed                      = false
    waad_common_endpoint           = false

    mfa {
      active = false
    }

    password_complexity_options {
      min_length = 8
    }

    password_dictionary {
      dictionary = []
      enable     = false
    }

    password_history {
      enable = false
      size   = 5
    }

    password_no_personal_info {
      enable = false
    }
  }
}
