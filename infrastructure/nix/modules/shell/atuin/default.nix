username:

{ pkgs, pkgs-unstable, lib, config, ... }:
with lib;

let
  cfg = config.modules.shell.atuin.${username};
  defaultConfig = import ./defaultConfig.nix cfg.sync_address;

in {
  options.modules.shell.atuin.${username} = {
    enable = lib.mkEnableOption "atuin";
    sync_address = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    config = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config.home-manager.users.${username} = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      package = pkgs-unstable.atuin;

      flags = [
        "--disable-up-arrow"
      ];

      settings = lib.mkMerge [
        defaultConfig
        cfg.config
      ];
    };
  };
}
