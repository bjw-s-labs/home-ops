{ pkgs, lib, config, options, ... }:
with lib;

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

    sops = {
      defaultSopsFile = ./secrets.sops.yaml;
      secrets = {
        atuin_key = { owner = config.users.users.${username}.name; };
      };
    };

    modules.home-manager.${username}.enable = true;
    modules.shell.atuin.${username} = {
      enable = true;
      sync_address = "https://atuin.bjw-s.dev";
      config = {
        key_path = config.sops.secrets.atuin_key.path;
      };
    };
    modules.shell.fish.${username}.enable = true;
    modules.shell.git.${username}.enable = true;
    modules.shell.starship.${username}.enable = true;
    modules.shell.tmux.${username}.enable = true;
  };
}
