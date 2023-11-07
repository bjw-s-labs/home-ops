username:

{ pkgs, pkgs-unstable, lib, config, ... }:
with lib;

let
  cfg = config.modules.shell.git.${username};

in {
  options.modules.shell.git.${username} = {
    enable = lib.mkEnableOption "git";
    config = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.gh.enable = true;
      programs.git = {
        enable = true;

        extraConfig = cfg.config;
      };
    };
  };
}
