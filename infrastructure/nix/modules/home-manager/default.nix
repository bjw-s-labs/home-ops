username:

{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.${username};
in {
  options.modules.home-manager.${username} = {
    enable = lib.mkEnableOption "fish";
  };

  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
    home-manager.users.${username} = {
      home = {
        stateVersion = "23.05";
      };

      programs = {
        home-manager.enable = true;
      };
    };
  };
}
