{ pkgs, lib, config, options, ... }:

let
  cfg = config.modules.users;
  username = "bjw-s";
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  config = lib.mkIf (builtins.elem username cfg.presetUsers) {
    users.users.${username} = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
      ] ++ ifGroupsExist [
        "network"
        "samba-users"
      ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyYn4k4V+myBBl79Nt3t7EZugvz9A+d3ZbKyaP1w7J5 Bernd personal"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINllIKQjpMumg9CCz1HIEsti/cN6MpUWZbCeLiLjKH2W Bernd iOS"
      ];
    };

    modules.home-manager = { enable = true; username=username; };

    modules.shell.fish = { enable = true; username=username; };
    modules.shell.starship = { enable = true; username=username; };
    modules.shell.atuin = {
      enable = true;
      username=username;
      sync_address = "https://atuin.bjw-s.dev";
    };
  };
}
