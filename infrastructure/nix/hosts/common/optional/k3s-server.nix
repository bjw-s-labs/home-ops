{ config, pkgs, lib, ... }:
{
  # This is required so that pod can reach the API server (running on port 6443 by default)
  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.unstable.k3s;
  };

  environment.systemPackages = [ pkgs.unstable.k3s ];
}
