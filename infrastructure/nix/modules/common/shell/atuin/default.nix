{ username }: {pkgs, lib, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.shell.atuin;
  defaultConfig = import ./defaultConfig.nix {sync_address=cfg.sync_address;};

in {
   options.modules.users.${username}.shell.atuin = {
    enable = mkEnableOption "${username} atuin";
    package = mkPackageOption pkgs "atuin" { };

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
      package = cfg.package;

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
