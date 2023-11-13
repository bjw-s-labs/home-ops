{ lib, config, ... }:
with lib;

let
  cfg = config.modules.system.openssh;
in {
  options.modules.system.openssh = { enable = mkEnableOption "openssh"; };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        # Harden
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        # Automatically remove stale sockets
        StreamLocalBindUnlink = "yes";
        # Allow forwarding ports to everywhere
        GatewayPorts = "clientspecified";
      };
    };

    security = mkIf cfg.enable {
      # Passwordless sudo when SSH'ing with keys
      pam.enableSSHAgentAuth = true;
    };
  };
}
