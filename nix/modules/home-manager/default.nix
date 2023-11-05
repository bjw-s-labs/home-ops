{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.home-manager;
in {
  options.modules.home-manager = {
    enable = lib.mkEnableOption "fish";
    username = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    }

    (lib.mkIf cfg.enable {
      home-manager.users.${config.modules.home-manager.username} = {
        home = {
          stateVersion = "23.05";
        };

        programs = {
          home-manager.enable = true;
        };
      };
    })
  ];
}
