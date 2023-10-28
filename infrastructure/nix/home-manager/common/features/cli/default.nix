{ pkgs, ... }:
{
  imports = [
    ./atuin.nix
    ./fish.nix
    ./starship.nix
  ];
  home.packages = with pkgs; [
    exa
    zoxide
  ];
}
