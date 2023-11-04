{ pkgs, lib, config, options, ... }:
with lib;
let
  cfg = config.modules.users;
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  config = mkIf (builtins.elem "manyie" cfg.presetUsers) {
    users.users.manyie = {
      isNormalUser = true;
      extraGroups = [
      ] ++ ifGroupsExist [
        "samba-users"
      ];
    };

    home-manager.users.manyie = mkAliasDefinitions options.home.manager;
  };
}
