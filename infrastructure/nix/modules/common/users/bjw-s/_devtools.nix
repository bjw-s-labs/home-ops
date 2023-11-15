{ pkgs, pkgs-unstable, ... }:
{
  modules.users.bjw-s.shell.rtx = {
    enable = true;
    package = pkgs-unstable.rtx;
  };

  home-manager.users.bjw-s.home.packages = [
    pkgs.envsubst
    pkgs.go-task
  ];
}
