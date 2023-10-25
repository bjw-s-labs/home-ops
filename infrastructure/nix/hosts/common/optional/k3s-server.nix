{ config, pkgs, lib, ... }:
{
  # This is required so that pod can reach the API server (running on port 6443 by default)
  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.unstable.k3s;
  };

  services.k3s.extraFlags = toString [
    "--tls-san" "${config.networking.hostName}.bjw-s.casa"
    "--disable" "local-storage"
    "--disable" "traefik"
  ];

  environment.systemPackages = [ pkgs.unstable.k3s ];
}
