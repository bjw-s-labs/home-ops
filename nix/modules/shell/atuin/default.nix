{ pkgs, pkgs-unstable, lib, config, ... }:

let
  cfg = config.modules.shell.atuin;
  defaultConfig = {
    sync_address = cfg.sync_address;
    auto_sync = true;
    sync_frequency = "1m";
    search_mode = "fuzzy";
  };
in {
  options.modules.shell.atuin = {
    enable = lib.mkEnableOption "atuin";
    sync_address = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    username = lib.mkOption {
      type = lib.types.str;
    };
    userConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config.home-manager.users.${cfg.username} = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      package = pkgs-unstable.atuin;

      flags = [
        "--disable-up-arrow"
      ];

      settings = lib.mkMerge [
        defaultConfig
        cfg.userConfig
      ];
    };
  };
}
