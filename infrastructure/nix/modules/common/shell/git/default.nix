{ username }: {lib, pkgs, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.shell.git;

in {
  options.modules.users.${username}.shell.git = {
    enable = mkEnableOption "${username} git";
    username = mkOption {
      type = types.str;
    };
    email = mkOption {
      type = types.str;
    };
    config = mkOption {
      type = types.attrs;
      default = {};
    };
    aliases = mkOption {
      type = types.attrs;
      default = {};
    };
    ignores = mkOption {
      type = types.listOf types.str;
      default = [];
    };
    includes = mkOption {
      type = types.listOf types.attrs;
      default = [];
    };
    signing = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.gh.enable = true;
      programs.git = {
        enable = true;
        userName = cfg.username;
        userEmail = cfg.email;

        extraConfig = cfg.config;
        aliases = cfg.aliases;
        ignores = cfg.ignores;
        includes = cfg.includes;
        signing = cfg.signing;
      };
      programs.gpg.enable = true;

      home.packages = [ pkgs.pinentry ];
    };
  };
}
