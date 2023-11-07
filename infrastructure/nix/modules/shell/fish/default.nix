username:

{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.shell.fish.${username};

  defaultConfig = import ./defaultConfig.nix;
in {
  options.modules.shell.fish.${username} = {
    enable = mkEnableOption "fish";
    config = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf (cfg.enable) {
    programs.fish.enable = true;

    home-manager.users.${username} = mkIf (cfg.enable) (mkMerge [
      defaultConfig
      cfg.config
    ]);
  };
}
