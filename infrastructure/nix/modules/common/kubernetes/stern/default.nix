{ username }: {pkgs,lib, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.kubernetes.k9s;

in {
  options.modules.users.${username}.kubernetes.k9s = {
    enable = mkEnableOption "${username} k9s";
    package = mkPackageOption pkgs "k9s" { };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.packages = [ cfg.package ];
    };
  };
}
