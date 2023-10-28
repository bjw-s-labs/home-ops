{ inputs, lib, pkgs, config, outputs, ... }:
{
  imports = [
    ./common/global
  ];

  home = {
    username = lib.mkDefault "bjw-s";
    homeDirectory = lib.mkDefault "/Users/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [ "$HOME/.local/bin" ];
  };

}
