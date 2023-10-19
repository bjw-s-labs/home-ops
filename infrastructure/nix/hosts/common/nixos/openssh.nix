{ outputs, lib, config, ... }:

let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
#   pubKey = host: ../../${host}/ssh_host_ed25519_key.pub;

in
{
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

  # Passwordless sudo when SSH'ing with keys
  security.pam.enableSSHAgentAuth = true;
}
