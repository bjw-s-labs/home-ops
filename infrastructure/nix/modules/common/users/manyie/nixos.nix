{ config, ... }:
let
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.manyie = {
    isNormalUser = true;
    extraGroups = [
    ] ++ ifGroupsExist [
      "samba-users"
    ];
  };
}
