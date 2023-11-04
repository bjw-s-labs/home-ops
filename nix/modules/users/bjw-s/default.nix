{ pkgs, lib, config, options, ... }:
with lib;
let
  cfg = config.modules.users;
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  config = mkIf (builtins.elem "bjw-s" cfg.presetUsers) {
    users.users.bjw-s = {
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

    home-manager.users.bjw-s = mkAliasDefinitions options.home.manager;

    modules.shell.fish.enable = true;
    modules.shell.atuin = {
      enable = true;
      sync_address = "https://atuin.bjw-s.dev";
    };
  };
}
