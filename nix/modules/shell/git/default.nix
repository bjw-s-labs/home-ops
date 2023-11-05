{ pkgs, pkgs-unstable, lib, config, ... }:

let
  cfg = config.modules.shell.git;
in {
  options.modules.shell.git = {
    enable = lib.mkEnableOption "git";
    username = lib.mkOption {
      type = lib.types.str;
    };
    userConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${cfg.username} = {
      programs.gh.enable = true;
      programs.git = {
        enable = true;

        extraConfig = cfg.userConfig;
      };
    };
  };
}
