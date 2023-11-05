{ pkgs, lib, config, options, ... }:

let
  cfg = config.modules.users;
  username = "manyie";
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  config = lib.mkIf (builtins.elem username cfg.presetUsers) {
    users.users.manyie = {
      isNormalUser = true;
      extraGroups = [
      ] ++ ifGroupsExist [
        "samba-users"
      ];
    };

    modules.shell.starship = {
      enable = true;
      username=username;
    };
  };
}
