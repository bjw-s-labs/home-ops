{ lib, config, ... }:
with lib;

let
  cfg = config.modules.servers.nfs;
in {
  options.modules.servers.nfs = {
    enable = mkEnableOption "nfs";
  };

  config = mkIf cfg.enable {
    services.nfs.server.enable = true;
    networking.firewall.allowedTCPPorts = [ 2049 ];
  };
}
