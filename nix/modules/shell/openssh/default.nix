{ lib, config, ... }:

let
  cfg = config.modules.shell.openssh;
in {
  options.modules.shell.openssh = { enable = lib.mkEnableOption "openssh"; };

  config.services.openssh = lib.mkIf cfg.enable {
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

  config.security = lib.mkIf cfg.enable {
    # Passwordless sudo when SSH'ing with keys
    pam.enableSSHAgentAuth = true;
  };
}
