{ username }: {pkgs,lib, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.shell.rtx;
  tomlFormat = pkgs.formats.toml { };

in {
  options.modules.users.${username}.shell.rtx = {
    enable = mkEnableOption "${username} rtx";
    package = mkPackageOption pkgs "rtx" { };

    enableFishIntegration = mkEnableOption "Fish Integration" // {
      default = true;
    };

    config = mkOption {
      type = tomlFormat.type;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.packages = [ cfg.package ];

      xdg.configFile."rtx/config.toml" = mkIf (cfg.config != { }) {
        source = tomlFormat.generate "rtx-config" cfg.config;
      };

      programs = {
        fish.shellInit = mkIf cfg.enableFishIntegration (
          mkAfter ''
            ${getExe cfg.package} hook-env | source
            ${getExe cfg.package} activate fish | source
          ''
        );
      };
    };
  };
}
