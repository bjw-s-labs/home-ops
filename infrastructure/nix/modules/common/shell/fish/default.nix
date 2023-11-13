{ username }: {lib, config, ... }:
with lib;
let
  cfg = config.modules.users.${username}.shell.fish;

  defaultConfig = import ./defaultConfig.nix;
in {
   options.modules.users.${username}.shell.fish = {
    enable = mkEnableOption "${username} fish";

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
