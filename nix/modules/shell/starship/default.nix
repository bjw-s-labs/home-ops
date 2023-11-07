username:

{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.shell.starship.${username};

  defaultConfig = import ./defaultConfig.nix;

in {
  options.modules.shell.starship.${username} = {
    enable = mkEnableOption "starship";

    config = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config.home-manager.users.${username} = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = mkMerge [
        defaultConfig
        cfg.config
      ];
    };
  };
}
