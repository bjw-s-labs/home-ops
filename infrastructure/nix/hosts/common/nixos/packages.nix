{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.tmux
  ];
}
