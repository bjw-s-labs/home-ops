{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./starship.nix
  ];
  home.packages = with pkgs; [
    exa
  ];
}
