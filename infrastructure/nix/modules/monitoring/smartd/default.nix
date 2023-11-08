{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.monitoring.smartd;
in {
  options.modules.monitoring.smartd = { enable = mkEnableOption "smartd"; };

  config = mkIf cfg.enable {
    services = {
      smartd = {
        enable = true;
        defaults.monitored = ''
          -a -o on -S on -n standby,q -s (S/../.././01|L/../../7/04:002) -W 4,40,45
        '';
        notifications = {
          mail = {
            enable = false;
          };
          wall.enable = false;
        };
      };
    };
    environment.systemPackages = [ pkgs.smartmontools ];
  };
}
