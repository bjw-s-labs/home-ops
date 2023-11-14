{ username }: {pkgs,lib, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.kubernetes.stern;

in {
  options.modules.users.${username}.kubernetes.stern = {
    enable = mkEnableOption "${username} stern";
    package = mkPackageOption pkgs "stern" { };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.packages = [ cfg.package ];
    };
  };
}
