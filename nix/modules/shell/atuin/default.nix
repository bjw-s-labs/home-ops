{ pkgs, pkgs-unstable, lib, config, ... }:
with lib;
let
  cfg = config.modules.shell.atuin;
in {
  options.modules.shell.atuin = {
    enable = mkEnableOption "atuin";

    sync_address = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs.fish.enable = true;

    modules.shell.starship.enable = true;

    home.manager = {
      programs.atuin = {
        enable = true;
        package = pkgs-unstable.atuin;

        flags = [
          "--disable-up-arrow"
        ];

        settings = {
          sync_address = cfg.sync_address;
          auto_sync = true;
          sync_frequency = "1m";
          search_mode = "fuzzy";
        };
      };
    };
  };
}
