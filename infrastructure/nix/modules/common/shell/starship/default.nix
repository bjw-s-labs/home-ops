{ username }: {lib, config, ... }:
with lib;
let
  cfg = config.modules.users.${username}.shell.starship;

  defaultConfig = import ./defaultConfig.nix;

in {
  options.modules.users.${username}.shell.starship = {
    enable = mkEnableOption "${username} starship";

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
