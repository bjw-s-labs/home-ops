# Always add to this file when adding new module
{ inputs, lib, pkgs, config, ... }:

let
  users = ["bjw-s" "manyie"];

  globalModules = [
    # Device options
    ./device.nix

    ./filesystem/zfs

    ./monitoring/smartd

    ./servers/nfs
    ./servers/k3s
    ./servers/samba

    ./shell/openssh

    ./system/cpu
    ./system/qemu-guest-agent
    ./system/video

    ./users
    ./users/bjw-s
    ./users/manyie
  ];

  userSpecificModules = [
    # Home manager config
    ./home-manager/default.nix

    # Shell config
    ./shell/atuin/default.nix
    ./shell/fish/default.nix
    ./shell/git/default.nix
    ./shell/starship/default.nix
    ./shell/tmux/default.nix
  ];
in {
  imports =
    # Host-level modules
    globalModules
    # User-specific modules
    ++ lib.flatten (lib.forEach users (userName:
    lib.forEach userSpecificModules (package:
      (import package userName)
    )
  ));
}
