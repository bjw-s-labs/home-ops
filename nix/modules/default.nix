# Always add to this file when adding new module
{ inputs, pkgs, config, ... }:

{
  imports = [
    # Device options
    ./device.nix

    # Home manager config
    ./home-manager

    # ./homelab/diy-keyboard
    # ./homelab/kubernetes

    # ./monitoring/smartd

    # ./multiplexer/tmux

    # ./program/default

    ./shell/atuin
    ./shell/fish
    ./shell/git
    # ./shell/lf
    ./shell/openssh
    ./shell/starship

    ./system/cpu
    ./system/video

    ./users
  ];
}
