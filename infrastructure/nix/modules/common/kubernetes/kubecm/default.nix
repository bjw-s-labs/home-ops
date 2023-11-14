{ username }: {pkgs,lib, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.kubernetes.kubecm;

in {
  options.modules.users.${username}.kubernetes.kubecm = {
    enable = mkEnableOption "${username} kubecm";
    package = mkPackageOption pkgs "kubecm" { };

    enableFishIntegration = mkEnableOption "Fish Integration" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    home-manager.users.${username} = {
      home.packages = [ cfg.package ];

      programs.fish = mkIf cfg.enableFishIntegration (
        {
          interactiveShellInit = ''
            ${getExe cfg.package} completion fish | source
          '';
          shellAliases = { kc = "kubecm"; };
        }
      );
    };
  };
}
