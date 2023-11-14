{ username }: {pkgs,lib, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.kubernetes.krew;

in {
  options.modules.users.${username}.kubernetes.krew = {
    enable = mkEnableOption "${username} krew";
    package = mkPackageOption pkgs "krew" { };

    enableFishIntegration = mkEnableOption "Fish Integration" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.packages = [ cfg.package ];

      programs = {
        fish.interactiveShellInit = mkIf cfg.enableFishIntegration (
          ''
            ${getExe cfg.package} completion fish | source
            fish_add_path $HOME/.krew/bin
          ''
        );
      };
    };
  };
}
