{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.bjw-s = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
    ] ++ ifTheyExist [
      "network"
      "samba-users"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyYn4k4V+myBBl79Nt3t7EZugvz9A+d3ZbKyaP1w7J5 Bernd personal"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBciX/nvTebsm25TIqTHj+LGPbUb3bbZG23I/rrCMCRK Bernd iOS"
    ];
  };
}
