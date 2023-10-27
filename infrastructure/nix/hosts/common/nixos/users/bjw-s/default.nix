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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINllIKQjpMumg9CCz1HIEsti/cN6MpUWZbCeLiLjKH2W Bernd iOS"
    ];

    packages = [ pkgs.home-manager ];
  };

  home-manager.users.bjw-s = import ../../../../../home-manager/bjw-s_${config.networking.hostName}.nix;
}
