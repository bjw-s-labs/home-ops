{ pkgs-unstable, lib, config, ... }:
with lib;

let
  deviceCfg = config.modules.device;
  cfg = config.modules.servers.k3s;
in {
  options.modules.servers.k3s = {
    enable = mkEnableOption "k3s";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 6443 ];

    services.k3s = {
      enable = true;
      role = "server";
      package = pkgs-unstable.k3s_1_27;
    };

    services.k3s.extraFlags = toString [
      "--tls-san=${config.networking.hostName}.${deviceCfg.domain}"
      "--disable=local-storage"
      "--disable=traefik"
    ];

    environment.systemPackages = [ pkgs-unstable.k3s_1_27 ];
  };
}
